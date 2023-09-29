# Importando pacotes
using CSV
using DataFrames
using Statistics 
using StatsPlots

# Importando csv
sw = CSV.File("data/starwars.csv") |> DataFrame

# Função personalizada para converter strings em Float64 ou Missing
function custom_parse(value)
    if value == "NA" || value == String3("NA")
        return missing
    else
        return parse(Float64, value)
    end
end

# Transforma a coluna "altura" em numérica, tratando "NA" como valor ausente (missing)
sw[!, :altura] = custom_parse.(sw[!, :altura])

# Transforma a coluna "massa" em numérica, tratando "NA" como valor ausente (missing)
sw[!, :massa] = custom_parse.(sw[!, :massa])


# Calculando quantos personagens de cada gênero existem

## Agrupa o DataFrame por gênero e conte o número de ocorrências em cada grupo
cont_genero = combine(groupby(sw, :genero), nrow)

## Renomeia a coluna resultante
rename!(cont_genero, :nrow => :quantidade)
total_personagens = sum(cont_genero[!, :quantidade])

## Calcula a porcentagem para cada gênero
cont_genero[!, :porcentagem] = (cont_genero[!, :quantidade] / total_personagens) * 100

## Quantidade de personagens por gênero
println(cont_genero)


# Calculando a altura e massa média dos personagens

## Agrupa o DataFrame por gênero
sw_genero = groupby(sw, :genero)

## Calcula a média de altura e massa para cada gênero
media_altura_massa = combine(sw_genero, 
    :altura => x -> mean(skipmissing(x)) => :altura_media, 
    :massa => x -> mean(skipmissing(x)) => :massa_media
)

# Transforma as colunas em numéricas e renomeia
media_altura_massa[!, :altura_function] = getindex.(media_altura_massa[!, :altura_function], 1)
media_altura_massa[!, :massa_function] = getindex.(media_altura_massa[!, :massa_function], 1)
rename!(media_altura_massa, :altura_function => :altura_media, :massa_function => :massa_media)

## Exibe o resultado
println(media_altura_massa)

# Plotando a relação entre altura e massa por gênero

# Remova as linhas com valores ausentes em altura e massa
sw2 = filter!(row -> !ismissing(row.altura) && !ismissing(row.massa), sw)


# Combine todos os gráficos em um único gráfico
plot_alturaxmassa_genero = 
@df sw2 scatter(:altura, :massa, group=:genero, xlabel="Altura (cm)", ylabel="Massa (kg)",
                title="Relação entre Altura e Massa por Gênero",
                legend=:topleft)

# Salvando o plot
savefig(plot_alturaxmassa_genero, joinpath("plots", "plot_alturaxmassa_genero.png"))

# Outlier
filter(row -> row.massa > 1200, sw2)