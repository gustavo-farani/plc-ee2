import Control.Concurrent
import Control.Concurrent.MVar
import Control.Monad
import Text.Printf
import System.IO

data Maquina = Refri Integer Integer Integer deriving (Show)

main = do
    hSetBuffering stdout NoBuffering
    server <- newMVar $ Refri 2000 2000 2000
    --client <- newEmptyMVar
    client <- newEmptyMVar
    --Client Threads
    forever $ forkIO $ do
        (Refri a b c) <- takeMVar server
        threadDelay 1000
        printf "O cliente 1 do refrigerante %s está enchenco seu copo\n" "Pepise-Cola"
        let atualizada = Refri (a-300) b c
        putMVar client atualizada
    --Server Thread
    forever $ forkIO $ do
        maquina <- takeMVar client
        let (atualizada, aux) = serverProcessing maquina
        case (aux) of
            Just (refrigerante, nova) -> do
                threadDelay 1500
                printf "O refrigerante %s foi reabastecido com 1000 ml, e agora possui %d ml\n" refrigerante nova
                putMVar server atualizada
            Nothing -> putMVar server atualizada

serverProcessing :: Maquina -> (Maquina, Maybe (String, Integer))
serverProcessing (Refri pepisecola polonorte quate)
    | pepisecola < 1000 = let nova = pepisecola + 1000 in (Refri nova polonorte quate, Just ("Pepise-Cola", nova))
    | polonorte < 1000 = let nova = polonorte + 1000 in (Refri pepisecola nova quate, Just ("Guaraná Polo Norte", nova))
    | quate < 1000 = let nova = quate + 1000 in (Refri pepisecola polonorte nova, Just ("Guaraná Quate", nova))
    | otherwise = (Refri pepisecola polonorte quate, Nothing)
