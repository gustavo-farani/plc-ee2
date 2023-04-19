import Control.Concurrent
import Control.Concurrent.MVar
import Control.Monad
import Text.Printf
import System.IO

data Maquina = Refri Integer Integer Integer deriving (Show)

main :: IO()
main = do
    let n1 = 2
    let n2 = 3
    let n3 = 4
    hSetBuffering stdout NoBuffering
    server <- newMVar $ Refri 2000 2000 2000
    client <- newEmptyMVar
    forkIO $ serverThread server client
    mapM_ (\k -> forkIO $ clientThread server client "Pepise-Cola" k) [1..n1]
    mapM_ (\k -> forkIO $ clientThread server client "Guaraná Polo Norte" k) [1..n2]
    mapM_ (\k -> forkIO $ clientThread server client "Guaraná Quate" k) [1..n3]
    return ()

clientThread :: MVar Maquina -> MVar Maquina -> String -> Integer -> IO()
clientThread server client refrigerante id = forever $ do
    maquina <- takeMVar server
    threadDelay $ 1000*1000
    printf "O cliente %d do refrigerante %s está enchendo seu copo\n" id refrigerante
    let atualizada = clientProcessing maquina refrigerante
    putMVar client atualizada

serverThread :: MVar Maquina -> MVar Maquina -> IO()
serverThread server client = forever $ do
    maquina <- takeMVar client
    let (atualizada, aux) = serverProcessing maquina
    case aux of
        Just (refrigerante, nova) -> do
            threadDelay $ 1500*1000
            printf "O refrigerante %s foi reabastecido com 1000 ml, e agora possui %d ml\n" refrigerante nova
            putMVar server atualizada
        Nothing -> putMVar server atualizada

serverProcessing :: Maquina -> (Maquina, Maybe (String, Integer))
serverProcessing (Refri pepisecola polonorte quate)
    | pepisecola < 1000 = let nova = pepisecola + 1000 in (Refri nova polonorte quate, Just ("Pepise-Cola", nova))
    | polonorte < 1000 = let nova = polonorte + 1000 in (Refri pepisecola nova quate, Just ("Guaraná Polo Norte", nova))
    | quate < 1000 = let nova = quate + 1000 in (Refri pepisecola polonorte nova, Just ("Guaraná Quate", nova))
    | otherwise = (Refri pepisecola polonorte quate, Nothing)

clientProcessing :: Maquina -> String -> Maquina
clientProcessing (Refri pepisecola polonorte quate) "Pepise-Cola" = Refri (pepisecola - 300) polonorte quate
clientProcessing (Refri pepisecola polonorte quate) "Guaraná Polo Norte" = Refri pepisecola (polonorte - 300) quate
clientProcessing (Refri pepisecola polonorte quate) "Guaraná Quate" = Refri pepisecola polonorte (quate - 300)
