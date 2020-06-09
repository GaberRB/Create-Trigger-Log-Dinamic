# Create-Trigger-Log-Dinamic

Cria uma trigger de log de forma dinâmica, apenas informando o nome da tabela será criado a tabela de registros e a trigger em um diretório especifico do banco de dados oracle.

Após Execução
Verificar O Output Do Caminho Da Geração Dos Arquivos.
 
Procedimento Para Criar Trigger De Log De Uma Respectiva Tabela,
Será Criado Com Base Em Todas As Colunas E Será Gravado Qualquer
Alteração De Update, Os Registros Serão Inseridos Na Tabela_log,
Ao Executar O Procedimento Será Gerado 2 Arquivos Txt, Para Criação
Da Tabela E Da Trigger;
 
Os Logs Serão Demostrados Da Seguinte Forma 
Tabela : Nome Da Tabela De Log
Chave : Primary Key Da Tabela
Data : Data De Alteração
Conteúdo: Coluna Vlrdesccomercial Alterado De 1 Para: 0
Vsuserbanco: Usuario Do Banco 
Vsterminal: Ip Da Maquina
Vsmodulo:  Aplicação 
Vsaction: Ação Realizada Via Banco   
Vsuserapp: Usuario Da Aplicação
Vsusermaq: Usuario Do Sistema Operacional  

<pre>
  <code>
    <span style="color: red">

DECLARE
DIRUTL VARCHAR2(4000);
NOMETABELA VARCHAR2(4000) := ''; --NOME DA TABELA PARA CRIAR LOG
VOUT VARCHAR2(4000);
BEGIN
  SELECT DIRECTORY_PATH
  INTO DIRUTL
  FROM ALL_DIRECTORIES
  WHERE DIRECTORY_NAME = 'ARQUIVOS'; 
  CRIA_TRIGGER_LOG(PTABELA => NOMETABELA, PDIRETORIO => DIRUTL);
  
  SELECT 'DIRETORIO: '||'\\'||UTL_INADDR.GET_HOST_ADDRESS(HOST_NAME)||'\ARQUIVOS'||CHR(13)||'BANCO: ' || HOST_NAME 
  INTO VOUT
  FROM V$INSTANCE;
  DBMS_OUTPUT.put_line(VOUT);
END;

</span>
  </code>
</pre>
