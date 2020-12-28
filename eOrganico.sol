// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.8.0;

/** 
 * @title eOrganico
 * @dev Contrato de itens orgânicos (Produção e Distribuição)
 * MDT-2020 - PUC-Rio - Grupo 6 - eOrganico
 */
contract ContratoEsperto {
    address payable eOrganico; // Chave da eOrganico
    
    // Assinaturas
    mapping(string => uint256) valoresPeriodos; // Períodos e seus valores

    // Credenciamentos
    mapping(address => uint256) fornecedoresCredenciados; // Fornecedores de sementes
    mapping(address => uint256) produtoresCredenciados;
    mapping(address => uint256) cooperativasCredenciadas;
    mapping(address => uint256) transportadorasCredenciadas;
    
    // Sementes
    mapping(address => mapping(string => uint256)) sementesCertificadas;
    
    // Produtos
    mapping(address => mapping(string => uint256)) produtosCertificados;
    

    constructor() {
        eOrganico = msg.sender;
    }
    
    function defineValorPeriodo(string calldata periodo, uint256 valor) public {
        require(msg.sender == eOrganico); // Só a eOrganico pode definir isso
        require(valor > 0, "Valor do periodo deve ser maior que zero");
        
        // TODO: O melhor seria usar enum ou algo parecido. Ou ao menos "normalizar" a string (maiúsculas, minúsculas, etc.)
        // TODO: Talvez devêssemos checar se estamos sobrescrevendo um valor que já exista
        // TODO: Em algum momento, podemos ter os valores históricos também. Ou a blockchain já resolve isso?
        valoresPeriodos[periodo] = valor;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Credenciamentos
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    function credenciaFornecedor(address payable fornecedor) public {
        require(msg.sender == eOrganico); // Só a eOrganico pode definir isso
        fornecedoresCredenciados[fornecedor] = block.timestamp; // Apenas para mapear alguma coisa...
    }
    
    function descredenciaFornecedor(address payable fornecedor) public {
        require(msg.sender == eOrganico); // Só a eOrganico pode definir isso
        fornecedoresCredenciados[fornecedor] = 0; // Remove o mapeamento
    }
    
    function verificaFornecedorCredenciado(address fornecedor) private view {
        require(fornecedoresCredenciados[fornecedor] != 0, "Fornecedor precisa estar credenciado");
    }
    
    function credenciaProdutor(address payable produtor) public {
        require(msg.sender == eOrganico); // Só a eOrganico pode definir isso
        produtoresCredenciados[produtor] = block.timestamp; // Apenas para mapear alguma coisa...
    }
    
    function descredenciaProdutor(address payable produtor) public {
        require(msg.sender == eOrganico); // Só a eOrganico pode definir isso
        produtoresCredenciados[produtor] = 0; // Remove o mapeamento
    }

    function verificaProdutorCredenciado(address produtor) private view {
        require(produtoresCredenciados[produtor] != 0, "Produtor precisa estar credenciado");
    }

    function credenciaCooperativa(address payable cooperativa) public {
        require(msg.sender == eOrganico); // Só a eOrganico pode definir isso
        cooperativasCredenciadas[cooperativa] = block.timestamp; // Apenas para mapear alguma coisa...
    }
    
    function descredenciaCooperativa(address payable cooperativa) public {
        require(msg.sender == eOrganico); // Só a eOrganico pode definir isso
        cooperativasCredenciadas[cooperativa] = 0; // Remove o mapeamento
    }
    
    function verificaCooperativaCredenciada(address cooperativa) private view {
        require(cooperativasCredenciadas[cooperativa] != 0, "Cooperativa precisa estar credenciada");
    }

    function credenciaTransportadora(address payable transportadora) public {
        require(msg.sender == eOrganico); // Só a eOrganico pode definir isso
        transportadorasCredenciadas[transportadora] = block.timestamp; // Apenas para mapear alguma coisa...
    }
    
    function descredenciaTransportadora(address payable transportadora) public {
        require(msg.sender == eOrganico); // Só a eOrganico pode definir isso
        transportadorasCredenciadas[transportadora] = 0; // Remove o mapeamento
    }

    function verificaTransportadoraCredenciada(address transportadora) private view {
        require(transportadorasCredenciadas[transportadora] != 0, "Transportadora' precisa estar credenciada");
    }

    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Sementes
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    function registraSementesCertificadas(string calldata produto, uint256 quantidade) public {
        address fornecedor = msg.sender;
        verificaFornecedorCredenciado(fornecedor);
        
        require(quantidade > 0, "Quantidade deve ser maior que zero");

        sementesCertificadas[fornecedor][produto] += quantidade; // Adiciona a quantidade de sementes
    }

    function compraSementes(address fornecedor, string calldata produto, uint256 quantidade) public {
        // TODO: Transformar de operação única para operação casada (Compra + Venda)
        // TODO: Transferir Ether também, para pagamento das sementes :-)

        address produtor = msg.sender;
        verificaProdutorCredenciado(produtor);
        verificaFornecedorCredenciado(fornecedor);
        require(quantidade > 0, "Quantidade deve ser maior que zero");

        // Verifica que fornecedor tem as sementes
        require(sementesCertificadas[fornecedor][produto] >= quantidade, "Fornecedor nao tem sementes suficientes");

        // Transfere as sementes
        sementesCertificadas[fornecedor][produto] -= quantidade;
        sementesCertificadas[produtor][produto] += quantidade;
    }

    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Produção
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    function registraProdutosCredenciados(string calldata produto, uint256 qtdSementes, uint256 qtdProdutos) public {
        address produtor = msg.sender;
        verificaProdutorCredenciado(produtor);
        
        require(qtdSementes > 0, "Quantidade de sementes utilizadas deve ser maior que zero");
        require(qtdProdutos > 0, "Quantidade de produtos gerados deve ser maior que zero");
        
        // TODO: Alguma verificação entre a quantidade de produtos e de sementes?
        
        // Verifica se o produtor tem as sementes
        require(sementesCertificadas[produtor][produto] >= qtdSementes);
        
        // Reduz as sementes
        sementesCertificadas[produtor][produto] -= qtdSementes;
        
        // Registra os produtos
        produtosCertificados[produtor][produto] += qtdProdutos;
    }

}
