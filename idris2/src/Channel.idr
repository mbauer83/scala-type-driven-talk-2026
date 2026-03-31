||| LAYER 4 — Session-Typed Channel Runtime
|||
||| Session p indexes channels by a runtime SessionType value.
||| In Scala, Chan[P] requires P to be a compile-time type.
||| Here, p is a plain SessionType value — computed at runtime if needed.
module Channel

import System.Concurrency   -- Channel a, makeChannel, channelGet, channelPut
import Data.List             -- replicate : Nat -> a -> List a
import SessionTypes
import Domain

%default covering

-- ─── Logger ───────────────────────────────────────────────────────────────────

private
bar : String
bar = pack (Data.List.replicate 70 '-')

export
logAction : String -> String -> IO ()
logAction op detail = putStrLn ("  [" ++ op ++ "]  " ++ detail)

export
logDecision : String -> String -> IO ()
logDecision op branch = putStrLn ("  [" ++ op ++ "]  branch -> " ++ branch)

export
section : String -> IO ()
section title = do
  putStrLn ("\n" ++ bar)
  putStrLn ("  " ++ title)
  putStrLn bar

export
note : String -> IO ()
note msg = putStrLn ("  [INFO]  " ++ msg)

export
outcome : String -> IO ()
outcome result = do
  putStrLn ("  > " ++ result)
  putStrLn bar

-- ─── Heterogeneous blob ───────────────────────────────────────────────────────

||| Opaque carrier for heterogeneous channel values.
||| packBlob / unpackBlob use believe_me; correctness is guaranteed by the
||| session type invariant: send always packs type a for Send a p, and recv
||| always unpacks type a for Receive a p, so the casts are always safe.
data Blob : Type where MkBlob : Blob   -- never actually constructed at runtime

packBlob : a -> Blob
packBlob = believe_me

unpackBlob : Blob -> a
unpackBlob = believe_me

-- ─── Session-typed channel ────────────────────────────────────────────────────

||| Session p: one end of a session in protocol state p.
|||
||| Internally backed by two System.Concurrency.Channel Blob queues
||| (one per direction).  channelGet blocks until a value is available,
||| so the protocol naturally synchronises client and server.
public export
data Session : SessionType -> Type where
  MkSession : Channel Blob  -- outbox: this end sends here
        -> Channel Blob  -- inbox:  this end reads from here
        -> Session p

||| Create a dual-channel pair.
||| The return type enforces: (Session p, Session (dual p)).
||| Impossible to create a pair where the protocols don't correspond.
public export
openSession : (p : SessionType) -> IO (Session p, Session (dual p))
openSession _ = do
  aToB <- makeChannel
  bToA <- makeChannel
  pure (MkSession aToB bToA, MkSession bToA aToB)

-- ─── Protocol operations ──────────────────────────────────────────────────────

public export
send : Session (Send a rest) -> a -> IO (Session rest)
send (MkSession out inp) val = do
  channelPut out (packBlob val)
  pure (MkSession out inp)

public export
sendLogged : Show a => Session (Send a rest) -> a -> IO (Session rest)
sendLogged (MkSession out inp) val = do
  logAction "SEND" (show val)
  channelPut out (packBlob val)
  pure (MkSession out inp)

public export
receive : Session (Receive a rest) -> IO (a, Session rest)
receive (MkSession out inp) = do
  blob <- channelGet inp
  pure (unpackBlob blob, MkSession out inp)

public export
receiveLogged : Show a => Session (Receive a rest) -> IO (a, Session rest)
receiveLogged (MkSession out inp) = do
  blob <- channelGet inp
  let val : a = unpackBlob blob
  logAction "RECV" (show val)
  pure (val, MkSession out inp)

public export
selectLeft : Session (Choose l r) -> IO (Session l)
selectLeft (MkSession out inp) = do
  logDecision "CHOOSE" "Left"
  channelPut out (packBlob True)
  pure (MkSession out inp)

public export
selectRight : Session (Choose l r) -> IO (Session r)
selectRight (MkSession out inp) = do
  logDecision "CHOOSE" "Right"
  channelPut out (packBlob False)
  pure (MkSession out inp)

public export
awaitChoice : Session (Offer l r) -> IO (Either (Session l) (Session r))
awaitChoice (MkSession out inp) = do
  blob <- channelGet inp
  let isLeft : Bool = unpackBlob blob
  logDecision "OFFER" (if isLeft then "Left" else "Right")
  if isLeft
    then pure (Left  (MkSession out inp))
    else pure (Right (MkSession out inp))

public export
finish : Session End -> IO ()
finish _ = logAction "CLOSE" "session complete"
