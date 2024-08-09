# Smart Money Contract

É um contrato simples que pode:
1. Receber depósitos de qualquer endereço.
2. Permitir que um usuário retire seus fundos.
3. Fazer transferências dos fundos de um usuário para outro endereço.

A restrição é que um endereço não pode retirar os fundos de outro endereço.

## Detalhes do projeto

* Tanto o [contrato](./src/SendWithdrawMoney.sol) quanto os [testes](./test/SendWithdrawMoney.t.sol) estão presentes neste projeto.
* O framework utilizado foi o [Foundry](https://book.getfoundry.sh/), ao instalar o framework digite ```forge build``` no terminal neste diretório.
* Para testar, digite ```forge test``` no terminal aberto neste diretório.