# 1. -----
# 1. Use o R para verificar o resultado da operação `7 + 7 ÷ 7 + 7 x 7 - 7`.

## Solução ------
7 + 7 / 7 + 7 * 7 - 7

# 2. -----
# 2. Verifique através do R se `3x2³` é maior que `2x3²`.

## Solução ------
3 * 2^3 > 2 * 3^2

# 3. -----
# 3. Crie dois objetos (qualquer nome) com os valores 100 e 300. 
# Multiplique esses objetos (função `prod()`) e atribuam ao objeto **mult**. 
# Faça o logaritmo natural (função `log()`) do objeto **mult** e atribuam ao objeto **ln**.

## Solução ------
obj1 <- 100
obj2 <- 300
mult <- prod(obj1, obj2)
ln <- log(obj1, obj2)

# 4. -----
# 4. Quantos pacotes existem no CRAN nesse momento? 
# Execute essa combinação no Console: 
# `nrow(available.packages(repos = "http://cran.r-project.org"))`.

## Solução ------
nrow(available.packages(repos = "http://cran.r-project.org"))

# 5. -----
# 5. Instale o pacote `tidyverse` do CRAN.

## Solução ------
install.packages("tidyverse", dependencies = TRUE)

# 6. -----
# 6. Escolha números para jogar na mega-sena usando o R, nomeando o objeto como **mega**. 
# Lembrando: são 6 valores de 1 a 60 e atribuam a um objeto.

## Solução ------
mega <- sample(x = 1:60, size = 6, replace = FALSE)

# 7. -----
# 7. Crie um fator chamado **tr**, com dois níveis ("cont" e "trat") para descrever 
# 100 locais de amostragem, 50 de cada tratamento. 
# O fator deve ser dessa forma `cont, cont, cont, ...., cont, trat, trat, ...., trat`.

## Solução ------
tr <- factor(c(rep("cont", each = 50), rep("trat", each = 50)))

# 8. -----
# 8. Crie uma matriz chamada **ma**, resultante da disposição de um vetor 
# composto por 1000 valores aleatórios entre 0 e 10. A matriz deve conter # 
# 100 linhas e ser disposta por colunas.

## Solução ------
ma <- matrix(sample(0:10, 1000, rep = TRUE), nrow = 100, byrow = FALSE)

# 9. -----
# 9. Crie um data frame chamado **df**, resultante da composição dos vetores: 
# i) `id: 1:50`
# ii) `sp: sp01, sp02, ..., sp49, sp50`
# iii) `ab: 50 valores aleatórios entre 0 a 5`

## Solução ------
df <- data.frame(id = 1:50,
                  sp = c(paste0("sp0", 1:9), paste0("sp", 10:50)),
                  ab = sample(0:5, 50, rep = TRUE))

# 10. -----
# 10. Crie uma lista com os objetos criados anteriormente: **mega**, **tr**, **ma** e **df**.

## Solução ------
lis <- list(mega, tr, ma, df)

# 11. -----
# 11. Selecione os elementos ímpares do objeto **tr** e atribua ao objeto **tr_impar**.

## Solução ------
tr_impar <- tr[seq(1, 99, 2)]

# 12. -----
# 12. Selecione as linhas com ids pares do objeto **df** e atribua ao objeto **df_ids_par**.

## Solução ------
df_ids_par <- df[seq(2, 100, 2), ]

# 13. -----
# 13. Faça uma amostragem de 10 linhas do objeto **df** e atribua ao objeto **df_amos10**.

## Solução ------
df_amos10 <- df[sample(nrow(df), 10), ]

# 14. -----
# 14. Amostre 10 linhas do objeto **ma**, mas utilizando as linhas amostradas do 
# **df_amos10** e atribua ao objeto **ma_amos10**.

## Solução ------
ma_amos10 <- ma[df_amos10$id, ]

# 15. -----
# 15. Una as colunas dos objetos **df_amos10** e **ma_amos10** e atribua ao 
# objeto **dados_amos10**.

## Solução ------
dados_amos10 <- cbind(df_amos10, ma_amos10)
