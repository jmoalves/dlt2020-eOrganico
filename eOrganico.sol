// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.8.0;

/** 
 * @title eOrganico
 * @dev Contrato de itens orgânicos (Produção e Distribuição)
 * MDT-2020 - PUC-Rio - Grupo 6 - eOrganico
 * 
 * TODO: Em algum momento, usar o mecanismo de transações casadas (Ex: Compra + Venda).
 * Há várias oportunidades no contrato (Compra/Venda de Sementes, Distribuição de Produtos, Entrega, etc.)
 */
contract ContratoEsperto {
    uint256 constant mes = 30 days; // TODO: Usar uma biblioteca de data!

    address payable eOrganico; // Chave da eOrganico
    
    // Assinaturas
    enum Periodos { Mensal, Trimestral, Anual }
    mapping(Periodos => uint256) valoresPeriodos; // Períodos e seus valores

    // Credenciamentos
    mapping(address => uint256) fornecedoresCredenciados; // Fornecedores de sementes
    mapping(address => uint256) produtoresCredenciados;
    mapping(address => uint256) cooperativasCredenciadas;
    mapping(address => uint256) transportadorasCredenciadas;
    
    // Assinaturas
    mapping(address => uint256) assinaturas; // cliente -> timestamp de expiração
    uint256 assinaturasVigentes = 0;
    uint256 maxAssinaturas = 0;

    // Sementes
    mapping(address => mapping(string => uint256)) sementesCertificadas;
    
    // Produtos
    mapping(address => mapping(string => uint256)) produtosCertificados;
    

    constructor() {
        eOrganico = msg.sender;
    }
    
    function defineValorPeriodo(Periodos periodo, uint256 valor) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");
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
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");
        require(fornecedor != eOrganico, "Parametro invalido");
        require(fornecedor != address(this), "Parametro invalido");

        fornecedoresCredenciados[fornecedor] = block.timestamp; // Apenas para mapear alguma coisa...
    }
    
    function descredenciaFornecedor(address payable fornecedor) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");
        require(fornecedor != eOrganico, "Parametro invalido");
        require(fornecedor != address(this), "Parametro invalido");

        fornecedoresCredenciados[fornecedor] = 0; // Remove o mapeamento
    }
    
    function verificaFornecedorCredenciado(address fornecedor) private view {
        require(fornecedoresCredenciados[fornecedor] != 0, "Fornecedor precisa estar credenciado");
    }
    
    function credenciaProdutor(address payable produtor) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");
        require(produtor != eOrganico, "Parametro invalido");
        require(produtor != address(this), "Parametro invalido");

        produtoresCredenciados[produtor] = block.timestamp; // Apenas para mapear alguma coisa...
    }
    
    function descredenciaProdutor(address payable produtor) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");
        require(produtor != eOrganico, "Parametro invalido");
        require(produtor != address(this), "Parametro invalido");

        produtoresCredenciados[produtor] = 0; // Remove o mapeamento
    }

    function verificaProdutorCredenciado(address produtor) private view {
        require(produtoresCredenciados[produtor] != 0, "Produtor precisa estar credenciado");
    }

    function credenciaCooperativa(address payable cooperativa) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");
        require(cooperativa != eOrganico, "Parametro invalido");
        require(cooperativa != address(this), "Parametro invalido");

        cooperativasCredenciadas[cooperativa] = block.timestamp; // Apenas para mapear alguma coisa...
    }
    
    function descredenciaCooperativa(address payable cooperativa) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");
        require(cooperativa != eOrganico, "Parametro invalido");
        require(cooperativa != address(this), "Parametro invalido");

        cooperativasCredenciadas[cooperativa] = 0; // Remove o mapeamento
    }
    
    function verificaCooperativaCredenciada(address cooperativa) private view {
        require(cooperativasCredenciadas[cooperativa] != 0, "Cooperativa precisa estar credenciada");
    }

    function credenciaTransportadora(address payable transportadora) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");
        require(transportadora != eOrganico, "Parametro invalido");
        require(transportadora != address(this), "Parametro invalido");

        transportadorasCredenciadas[transportadora] = block.timestamp; // Apenas para mapear alguma coisa...
    }
    
    function descredenciaTransportadora(address payable transportadora) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");
        require(transportadora != eOrganico, "Parametro invalido");
        require(transportadora != address(this), "Parametro invalido");

        transportadorasCredenciadas[transportadora] = 0; // Remove o mapeamento
    }

    function verificaTransportadoraCredenciada(address transportadora) private view {
        require(transportadorasCredenciadas[transportadora] != 0, "Transportadora' precisa estar credenciada");
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Assinaturas
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    function informaAssinaturasDisponiveis(uint256 quantidade) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");

        // TODO: Tem que tratar as assintaturas que expiraram
        require(quantidade >= assinaturasVigentes, "Ja ha mais assinaturas vigentes do que o informado");
        
        maxAssinaturas = quantidade;
    }

    function assinaServico(Periodos periodo) public payable returns (uint256) {
        require(msg.sender != eOrganico, "eOrganico nao pode usar o servico");

        address payable cliente = msg.sender;
        require(assinaturas[cliente] == 0, "Cliente ja eh assinante"); // TODO: Tratar as assinaturas que expiraram

        require(valoresPeriodos[periodo] > 0, "Sem valor para o periodo");
        require(msg.value >= valoresPeriodos[periodo], "Valor insuficiente para o periodo");
        require(assinaturasVigentes < maxAssinaturas, "Nao ha mais assinaturas disponiveis");

        uint256 vigencia = calculaVigencia(periodo);
        require(vigencia > block.timestamp, "Vigencia invalida");

        uint256 inicio = calculaInicioFornecimento();
        require(inicio > block.timestamp, "Inicio invalido");
        
        assinaturasVigentes++;
        assinaturas[cliente] = vigencia;

        uint256 troco = msg.value - valoresPeriodos[periodo];
        if (troco > 0) {
            msg.sender.transfer(troco);
        }
        
        return inicio;
    }

    function calculaVigencia(Periodos periodo) private view returns (uint256) {
        if (periodo == Periodos.Anual) {
            return block.timestamp + 12 * mes;
        }
        
        if (periodo == Periodos.Trimestral) {
            return block.timestamp + 3 * mes;
        }

        if (periodo == Periodos.Mensal) {
            return block.timestamp + 1 * mes;
        }
        
        return 0;
    }

    function calculaInicioFornecimento() private view returns (uint256) {
        // Sempre 15 dias depois
        // TODO: Usar outros parametros para calcular esse prazo?
        return block.timestamp + 15 days;
    }

    function verificaCliente(address cliente) private view {
        require(assinaturas[cliente] > block.timestamp, "Nao possui assinatura vigente");
    }

    function cancelaAssinatura(address payable cliente) public {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");

        trataCancelamentoAssinatura(cliente);
    }
    
    function cancelaAssinatura() public {
        require(msg.sender != eOrganico, "eOrganico nao pode usar o servico");

        address payable cliente = msg.sender;
        require(assinaturas[cliente] != 0, "Nao eh cliente para cancelar assinatura");
        
        trataCancelamentoAssinatura(cliente);
    }
    
    function trataCancelamentoAssinatura(address payable cliente) private {
        require(msg.sender == eOrganico || (msg.sender == cliente && assinaturas[msg.sender] != 0) , "Solicitante invalido");
        
        uint256 devolucao = calculaDevolucaoAssinatura(assinaturas[cliente]);
        assinaturas[cliente] = 0;
        assinaturasVigentes--;
        
        if (devolucao > 0) {
            cliente.transfer(devolucao);
        }
    }

    function calculaDevolucaoAssinatura(uint256 expiracao) private view returns (uint256) {
        if (expiracao <= block.timestamp) {
            return 0;
        }
        
        uint256 diasRestantes = (expiracao - block.timestamp) / 1 days;
        if (diasRestantes < 30) {
            return 0;
        }
        
        uint256 mesesRestantes = diasRestantes / mes;
        if (mesesRestantes < 1) {
            return 0;
        }
        
        // BUG!!! Se os periodos tiverem valores diferentes, pode gerar devolver mais do que pagou
        // BUG!!! Se o periodo Mensal não estiver definido, não devolve nada
        uint256 devolucao = mesesRestantes * valoresPeriodos[Periodos.Mensal];
        return devolucao;
    }

    function consultaAssinaturasVigentes() public view returns (address[] memory) {
        require(msg.sender == eOrganico, "Somente eOrganico pode usar esse servico");

        // FIXME: Não é possível listar as assinaturas vigentes - Precisamos trocar de estrutura de armazenamento
        // TODO: Usar IterableMappings - https://docs.soliditylang.org/en/v0.7.0/types.html#iterable-mappings
        return new address[](0);
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Sementes
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    function registraSementesCertificadas(string calldata produto, uint256 quantidade) public {
        require(msg.sender != eOrganico, "eOrganico nao pode usar o servico");

        address fornecedor = msg.sender;
        verificaFornecedorCredenciado(fornecedor);
        
        require(quantidade > 0, "Quantidade deve ser maior que zero");

        sementesCertificadas[fornecedor][produto] += quantidade; // Adiciona a quantidade de sementes
    }

    function compraSementes(address fornecedor, string calldata produto, uint256 quantidade) public {
        require(msg.sender != eOrganico, "eOrganico nao pode usar o servico");

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
        require(msg.sender != eOrganico, "eOrganico nao pode usar o servico");

        address produtor = msg.sender;
        verificaProdutorCredenciado(produtor);
        
        require(qtdSementes > 0, "Quantidade de sementes utilizadas deve ser maior que zero");
        require(qtdProdutos > 0, "Quantidade de produtos gerados deve ser maior que zero");
        
        // TODO: Alguma verificação entre a quantidade de produtos e de sementes?
        
        // Verifica se o produtor tem as sementes
        require(sementesCertificadas[produtor][produto] >= qtdSementes, "Produtor nao tem sementes suficientes");

        // Reduz as sementes
        sementesCertificadas[produtor][produto] -= qtdSementes;

        // Registra os produtos
        produtosCertificados[produtor][produto] += qtdProdutos;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Distribuição
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    function cooperativaRecebeProdutos(address produtor, string calldata produto, uint256 qtdProdutos) public {
        require(msg.sender != eOrganico, "eOrganico nao pode usar o servico");

        address cooperativa = msg.sender;
        verificaCooperativaCredenciada(cooperativa);
        verificaProdutorCredenciado(produtor);
        
        require(qtdProdutos > 0, "Quantidade de produtos deve ser maior que zero");
        
        // Verifica se o produtor tem os produtos
        require(produtosCertificados[produtor][produto] >= qtdProdutos, "Produtor nao tem produtos suficientes");

        // Transfere os produtos
        produtosCertificados[produtor][produto] -= qtdProdutos;
        produtosCertificados[cooperativa][produto] += qtdProdutos;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Despacho
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    function transportadoraRecebeProdutos(address cooperativa, string calldata produto, uint256 qtdProdutos) public {
        require(msg.sender != eOrganico, "eOrganico nao pode usar o servico");

        address transportadora = msg.sender;
        verificaTransportadoraCredenciada(transportadora);
        verificaCooperativaCredenciada(cooperativa);
        
        require(qtdProdutos > 0, "Quantidade de produtos deve ser maior que zero");
        
        // Verifica se a cooperativa tem os produtos'
        require(produtosCertificados[cooperativa][produto] >= qtdProdutos, "Cooperativa nao tem produtos suficientes");

        // Transfere os produtos
        produtosCertificados[cooperativa][produto] -= qtdProdutos;
        produtosCertificados[transportadora][produto] += qtdProdutos;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Entrega
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    function clienteRecebeProdutos(address transportadora, string calldata produto, uint256 qtdProdutos) public {
        require(msg.sender != eOrganico, "eOrganico nao pode usar o servico");

        address cliente = msg.sender;
        verificaCliente(cliente);
        verificaTransportadoraCredenciada(transportadora);

        require(qtdProdutos > 0, "Quantidade de produtos deve ser maior que zero");
        
        // Verifica se a transportadora tem os produtos'
        require(produtosCertificados[transportadora][produto] >= qtdProdutos, "Transportadora nao tem produtos suficientes");

        // Transfere os produtos
        produtosCertificados[transportadora][produto] -= qtdProdutos;
        produtosCertificados[cliente][produto] += qtdProdutos;
        
        // TODO: Aqui, só acumula... O que fazer com a quantidade de produtos com o cliente?
    }
}
