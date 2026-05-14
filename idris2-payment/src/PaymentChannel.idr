||| Minimal session-typed runtime, shared by all payment demos.
module PaymentChannel

import System.Concurrency
import Data.List
import PaymentSessionTypes

%default covering

private
bar : String
bar = pack (replicate 72 '=')

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
logAction : String -> String -> IO ()
logAction op detail = putStrLn ("  [" ++ op ++ "]  " ++ detail)

export
logDecision : String -> String -> IO ()
logDecision op detail = putStrLn ("  [" ++ op ++ "]  " ++ detail)

export
outcome : String -> IO ()
outcome msg = do
  putStrLn ("  > " ++ msg)
  putStrLn bar

data Blob : Type where
  MkBlob : Blob

packBlob : a -> Blob
packBlob = believe_me

unpackBlob : Blob -> a
unpackBlob = believe_me

public export
data Session : SessionType -> Type where
  MkSession : Channel Blob -> Channel Blob -> Session p

public export
openSession : (p : SessionType) -> IO (Session p, Session (dual p))
openSession _ = do
  aToB <- makeChannel
  bToA <- makeChannel
  pure (MkSession aToB bToA, MkSession bToA aToB)

public export
send : Session (Send a rest) -> a -> IO (Session rest)
send (MkSession out inp) value = do
  channelPut out (packBlob value)
  pure (MkSession out inp)

public export
sendLogged : Show a => Session (Send a rest) -> a -> IO (Session rest)
sendLogged (MkSession out inp) value = do
  logAction "SEND" (show value)
  channelPut out (packBlob value)
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
  let value : a = unpackBlob blob
  logAction "RECV" (show value)
  pure (value, MkSession out inp)

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
  let chooseLeft : Bool = unpackBlob blob
  if chooseLeft
    then do
      logDecision "OFFER" "Left"
      pure (Left (MkSession out inp))
    else do
      logDecision "OFFER" "Right"
      pure (Right (MkSession out inp))

public export
finish : Session End -> IO ()
finish _ = logAction "CLOSE" "session complete"
