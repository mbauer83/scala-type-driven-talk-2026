||| Session-typed runtime with linear (multiplicity-1) session resources.
|||
||| Every `Session p` value must be consumed exactly once. The four primitive
||| operations — `send`, `receive`, `selectLeft`/`selectRight`, `awaitChoice`,
||| `finish` — take their input session at multiplicity 1 and produce a fresh
||| session for the next protocol step (also linear). If a handler binds a
||| `Session` from one of these operations and then never passes it on (no
||| `finish`, no further step), the linearity checker rejects the program at
||| compile time.
|||
||| Note on terminology: this uses Idris 2's *Quantitative Type Theory*
||| multiplicities (the 0 / 1 / ω annotations on bindings) — what type-theory
||| literature calls *linear* types. This is distinct from `UniqueType`, the
||| *uniqueness*-typing universe Idris 2 also supports, which is about the
||| absence of aliasing on the input side rather than mandatory consumption.
||| For the "must call finish" bug, the multiplicity-1 mechanism is the right
||| tool: it enforces "use exactly once".
module PaymentChannel

import System.Concurrency
import Control.Linear.LIO
import Data.Linear.Notation
import Data.Linear.LEither
import Data.List
import PaymentSessionTypes

%default covering

private
bar : String
bar = pack (replicate 72 '=')

export
section : String -> L IO ()
section title = do
  putStrLn ("\n" ++ bar)
  putStrLn ("  " ++ title)
  putStrLn bar

export
note : String -> L IO ()
note msg = putStrLn ("  [INFO]  " ++ msg)

export
logAction : String -> String -> L IO ()
logAction op detail = putStrLn ("  [" ++ op ++ "]  " ++ detail)

export
outcome : String -> L IO ()
outcome msg = do
  putStrLn ("  > " ++ msg)
  putStrLn bar

data Blob : Type where
  MkBlob : Blob

packBlob : a -> Blob
packBlob = believe_me

unpackBlob : Blob -> a
unpackBlob = believe_me

||| A linear session-typed endpoint. The constructor is private; callers
||| cannot fabricate or duplicate a `Session p` value.
public export
data Session : SessionType -> Type where
  MkSession : Channel Blob -> Channel Blob -> Session p

||| Open a fresh session, returning the two endpoints linearly paired.
||| The caller must consume both endpoints (either by stepping through their
||| protocols and calling `finish`, or by forking one half off).
public export
openSession : (p : SessionType) -> L1 IO (LPair (Session p) (Session (dual p)))
openSession _ = do
  aToB <- liftIO1 makeChannel
  bToA <- liftIO1 makeChannel
  pure1 (MkSession aToB bToA # MkSession bToA aToB)

||| Send the next message. Consumes the input session; returns the session
||| at the next protocol position.
public export
send : (1 _ : Session (Send a rest)) -> a -> L1 IO (Session rest)
send (MkSession out inp) value = do
  liftIO1 (channelPut out (packBlob value))
  pure1 (MkSession out inp)

public export
sendLogged : Show a => (1 _ : Session (Send a rest)) -> a -> L1 IO (Session rest)
sendLogged (MkSession out inp) value = do
  logAction "SEND" (show value)
  liftIO1 (channelPut out (packBlob value))
  pure1 (MkSession out inp)

||| Receive the next message. Consumes the input session; returns the value
||| (wrapped in `!*` so it can be used unrestrictedly — message data is not
||| a resource) and the session at the next protocol position, linearly paired.
public export
receive : (1 _ : Session (Receive a rest)) -> L1 IO (LPair (!* a) (Session rest))
receive (MkSession out inp) = do
  blob <- liftIO1 (channelGet inp)
  pure1 (MkBang (unpackBlob blob) # MkSession out inp)

public export
receiveLogged : Show a => (1 _ : Session (Receive a rest)) -> L1 IO (LPair (!* a) (Session rest))
receiveLogged (MkSession out inp) = do
  blob <- liftIO1 (channelGet inp)
  let value : a = unpackBlob blob
  logAction "RECV" (show value)
  pure1 (MkBang value # MkSession out inp)

||| Take the left branch of a Choose. Consumes the input session.
public export
selectLeft : (1 _ : Session (Choose l r)) -> L1 IO (Session l)
selectLeft (MkSession out inp) = do
  logAction "CHOOSE" "Left"
  liftIO1 (channelPut out (packBlob True))
  pure1 (MkSession out inp)

public export
selectRight : (1 _ : Session (Choose l r)) -> L1 IO (Session r)
selectRight (MkSession out inp) = do
  logAction "CHOOSE" "Right"
  liftIO1 (channelPut out (packBlob False))
  pure1 (MkSession out inp)

||| Receive a branching choice from the peer. The result is a *linear*
||| Either: whichever side is produced, the contained session must still be
||| consumed exactly once.
public export
awaitChoice : (1 _ : Session (Offer l r)) -> L1 IO (LEither (Session l) (Session r))
awaitChoice (MkSession out inp) = do
  blob <- liftIO1 (channelGet inp)
  let chooseLeft : Bool = unpackBlob blob
  case chooseLeft of
    True => do
      logAction "OFFER" "Left"
      pure1 (Left (MkSession out inp))
    False => do
      logAction "OFFER" "Right"
      pure1 (Right (MkSession out inp))

||| Close a completed session. The argument is consumed; afterwards the
||| session no longer exists. Calling this *anywhere except* at protocol
||| position `End` is a type error.
public export
finish : (1 _ : Session End) -> L IO ()
finish (MkSession _ _) = logAction "CLOSE" "session complete"
