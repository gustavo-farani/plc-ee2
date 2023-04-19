math.randomseed(os.time())

vida_pikachu = 800
vida_raichu = 1000

function atacar(nome_atacante, nome_alvo)
    while vida_pikachu > 0 and vida_raichu > 0 do
        pontuacao_ataque = math.random(1, 20)
        
        if (pontuacao_ataque <= 10) then
            ataque_utilizado = "Choque do Trovão"
            pontuacao_perdida = 50
        elseif (pontuacao_ataque >= 11 and pontuacao_ataque <= 15) then
            ataque_utilizado = "Calda de Ferro"
            pontuacao_perdida = 100
        elseif (pontuacao_ataque >= 16 and pontuacao_ataque <= 18) then
            ataque_utilizado = "Investida do Trovão"
            pontuacao_perdida = 150
        else
            ataque_utilizado = "Trovão"
            pontuacao_perdida = 200
        end

        if nome_atacante == "Pikachu" then
            vida_raichu = vida_raichu - pontuacao_perdida
        else
            vida_pikachu = vida_pikachu - pontuacao_perdida
        end

        print("Relatório de batalha:")
        print(nome_atacante .. " utiliza o ataque " .. ataque_utilizado)
        print(nome_alvo .. " perdeu " .. pontuacao_perdida .. " devido ao ataque de " .. nome_atacante)
        print("Vida do Pikachu: " .. vida_pikachu)
        print("Vida do Raichu: " .. vida_raichu)
        print("______________")

        coroutine.yield()
    end
end

pikachu = coroutine.create(function()
    atacar("Pikachu", "Raichu")
end)

raichu = coroutine.create(function()
    atacar("Raichu", "Pikachu")
end)

while true do
    coroutine.resume(pikachu)
    coroutine.resume(raichu)

    if vida_pikachu <= 0 or vida_raichu <= 0 then
        break
    end
end

if vida_pikachu <= 0 then
    print("Vitória do Raichu")
else
    print("Vitória do Pikachu")
end
