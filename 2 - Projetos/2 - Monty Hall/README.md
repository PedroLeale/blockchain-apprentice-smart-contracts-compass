# Monty Hall in Solidity

* Implementação de um Smart Contract do jogo Monty Hall seguindo a teoria dos jogos e punindo tentavias de prejudicar o outro participante.
* Contrato feito utilizando framework Foundry, para testar instale o framework e use ```forge build``` e ```forge test``` no terminal neste diretório.
* Caso queira fazer deploy, crie um arquivo ```.env``` e o preencha de acordo com o exemplo, carregue as variáveis usando dotenv ou alguma aplicação parecida ```source .env``` e rode o script: ```forge script script/MontyHallScript.s.sol --fork-url ${SEPOLIA_RPC_URL} --broadcast -vvvv```.
* Código fonte está na pasta [src/](./src/) e os testes estão em [test/](./test/).
* Foi feito deploy do contrato na rede testnet Sepolia, endereço [0x821dC5CC6692544CdC6F8F619E41f3cb7F662aEd](https://sepolia.etherscan.io/address/0x821dC5CC6692544CdC6F8F619E41f3cb7F662aEd) com tempo de 30 dias para cada etapa.

## Funcionamento do jogo

1. O apresentador faz o deploy do contrato com as portas, utilizando o protocolo Commit, o colateral para a participação do jogador e o tempo limite de cada etapa do jogo.
2. O contrato possui 4 estados: _Bet_, _Reveal_, _Change_, _FinalReveal_ e _Done_. Ao fazer o deploy, o contrato inicia no estado _Bet_, aguardando o jogador fazer sua aposta, pagando o colateral e escolhendo uma porta.
3. Em seguida, o apresentador, ciente da escolha do jogador, revela uma das outras duas portas, mudando o estado do contrato para _Change_.
4. No estado _Change_, o jogador tem a opção de mudar a escolha da porta. Caso queira trocar, use a função `change(uint8 door) public onlyPlayer` com o novo número da porta. Se não desejar trocar, chame essa função com o mesmo número utilizado anteriormente. Ao realizar essa função com sucesso, o estado mudará para _FinalReveal_.
5. No estado _FinalReveal_, o apresentador revela as últimas portas, e as premiações são decididas.

## Regras

* Caso um dos participantes não aja dentro do tempo limite, a função ```reclaimTimeLimit() public``` permite que o outro recupere seu dinheiro, possivelmente punindo o participante que não agiu, como o apresentador pegando o colateral do jogador ou o jogador pegando o prêmio antes do término do jogo.
* Se o apresentador revelar a porta que contém o prêmio na fase _Reveal_, o jogo termina e o jogador é declarado vencedor.
* Durante as revelações finais, se for descoberto que o apresentador não colocou uma porta premiada, o jogador é declarado vencedor. Além disso, se o protocolo Commit falhar, seja por um valor de Commit incorreto ou tentativa de fraude, o jogador também é premiado.
* O contrato emite eventos quando todas as portas são reveladas e quando um dos participantes vence.

## Testes

* Foram feitos 11 testes, tanto em casos em que o jogo é honesto quanto nos casos em que tentam trapacear ou não respeitam as limitações de tempo.