# Smart Contracts / Contratos inteligentes e Solidity

- [Oque são Smart Contracts ?](#o-que-são-smart-contracts)
- [Blockchains](#blockchains)
- [Carterias virtuais](#carteiras-virtuais)
- [Solidity](#solidity)
- [Tokens](#tokens)

## o que são Smart Contracts?

* São programas hospedados em Blockchains que executam ações quando certas condições são atendidas.
* São Turing-Completos.
* São autônomos, não necessitam de entidades os controlando.
* Por padrão são imutáveis e transparentes, oferecendo segurança para as transações.
  * Existem certas condições para fazer um contrato __Upgradeable__, mas ele ainda mantém algumas partes imutáveis.
  * Sobre a transparência, existem técnicas de criptografia como protocolo Commit ou Zero-Knowledge-Proof para diminuir a transparência até certo ponto.
* A linguagem de programação mais popular para criá-los é [Solidity](https://soliditylang.org/)

## Blockchains

* A plataforma mais popular que da suporte a Smart Contracts é Ethereum, porém existem outras como Polygon, Binance Smart Chain, etc....
* Transações que alteram o estado da blockchain custam Gas, o mesmo acontece com um contrato, ao realizar transações de escrita com um contrato será cobrado a taxa de Gas do usuário. Transações de leitura não tem esse custo.

## Carteiras virtuais

* Softwares chamados carteiras virtuais existem em uma camada acima da Blockchain, são abstrações que ajudam o usuário realizar transações. Existem diversos tipos de carteiras para ajudar gerenciar os pares de chaves, um dos mais populares é o [Metamask](https://metamask.io/)
  * Mas lembre-se, são só abstrações, se um dia estes softwares pararem de funcionar os usuários não vão perder seus tokens desde que saibam seus pares de chaves.

## Solidity

### Introdução

* Linguagem de alto nível para implementação de Smart Contracts, influenciada por Javascript (ou ECMAscript).
* É estaticamente tipada e compilada, além de ter conceitos que lembram orientação a objetos.
* Dentre seus frameworks os mais famosos são: [Hardhat](https://hardhat.org/), [Truffle](https://archive.trufflesuite.com/) e [Foundry](https://book.getfoundry.sh/).

### Estrutura de um contrato

* Estrutura similar a uma classe em outras linguagens
* Tem funções
  * Funções do tipo __view__ não são cobrados taxa de Gas
* Estruturas de controle
  * If/Else
* Loops
  * For/While
* Tipos de dados
  * (U)Int, Boolean, Arrays
  * Struct, Mapping, Address (tipo para representar endereços)
  * Não possui __Float!!!__
* Contém Heranças
* Estruturas especiais como __Modifiers__
* Tem imports como a maioria das linguagens

### Funções de transferência

* __transfer__ : Da erro caso ultrapasse o limite de 2300 de gas.
* __send__: Retorna booleano com o limite de 2300 de gas.
* __call__: Encaminha todo o gás ou define a quantidade de gás, retorna um valor booleano

Porém __!!CUIDADO!!__ com o ataque de reentrância. Trata-se de uma vulnerabilidade em que um contrato chama uma função externa que, por sua vez, faz uma chamada de volta para a função original antes que sua execução seja concluída. Esse ataque pode permitir que um usuário retire fundos múltiplas vezes de um contrato. Para evitar essa vulnerabilidade, é recomendável adotar algumas práticas de proteção, como o uso de um [Reentrancy Guard](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard). <br>
Este ataque quando aconteceu pela primeira vez, gerou inúmeras discussões e até um Fork da rede Ethereum.

### Exemplo

* Contrato retirado da documentação da linguagem: https://docs.soliditylang.org/en/latest/introduction-to-smart-contracts.html.
* O contrato a seguir implementa a forma mais simples de uma criptomoeda. O contrato permite que apenas seu criador crie novas moedas (diferentes esquemas de emissão são possíveis). Qualquer pessoa pode enviar moedas para outras desde que tenha acesso a um par de chaves Ethereum.

```Solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

// This will only compile via IR
contract Coin {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
    mapping(address => uint) public balances;

    // Events allow clients to react to specific
    // contract changes you declare
    event Sent(address from, address to, uint amount);

    // Constructor code is only run when the contract
    // is created
    constructor() {
        minter = msg.sender;
    }

    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
    }

    // Errors allow you to provide information about
    // why an operation failed. They are returned
    // to the caller of the function.
    error InsufficientBalance(uint requested, uint available);

    // Sends an amount of existing coins
    // from any caller to an address
    function send(address receiver, uint amount) public {
        require(amount <= balances[msg.sender], InsufficientBalance(amount, balances[msg.sender]));
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}
```

## Tokens

### Introdução

* _Tokens são a representação de algo na blockchain_. [OpenZeppelin](https://docs.openzeppelin.com/contracts/2.x/tokens)
  * Este algo não tem uma restrição necessariamente dita, pode ser dinheiro, serviços, tempo, etc...
* Um _Contrato de Token_ é simplesmente um Smart Contract que mapeia saldo e endereços, em conjunto com algumas regras de cada Token em específico para adicionar ou subtrair.
* Dizer que alguém tem Tokens quer dizer que o saldo no contrato de tokens é diferente de zero.

### Tipos de Tokens

* Existem diversos padrões de tokens, cada um com suas características mas eles geralmente se dividem entre "fungíveis" e "não-fungíveis"
  * Fungíveis: quer dizer que os tokens são equivalentes e intercambeáveis. Exemplo: Moedas, moedas de mesmo valor podem ser trocadas entre si pos terão sempre o mesmo valor.
  * Não-fungíveis: quer dizer que são únicos e distintos. Exemplo: Peças de arte como quadros, músicas, esculturas, são únicas e não da pra dizer que tem o mesmo valor pra trocar entre si.

### Padrões mais populares

* __ERC20__: Padrão de token fungível mais popular, é extremamente simples.
* __ERC777__: Padrão de token fungível com mais funções, permitindo mais casos de uso. É retrocompatível com o padrão __ERC20__.
* __ERC721__: Padrão de token não-fungível, geralmente utilizado para colecionáveis.

### Outros tipos de Tokens

* Além dos padrões, ainda existem outros tipos como Tokens de governância. São tokens utilizados como poder de voto em contratos mais complexos como DAOs (Decentralized Autonomous Organization).
* Estes Tokens podem ser criados especificamente para o caso, ou serem usados com base em padrões.