CREATE OR REPLACE PROCEDURE CRIA_TRIGGER_LOG (PTABELA IN VARCHAR, PDIRETORIO IN VARCHAR)
IS
  /*
  FONTE GERADOR DE TRIGGER DE LOG, RECEBE A TABELA COMO PARAMETRO E GERA UM ARQUIVO
  DE SCRIPT PARA A GERAÇÃO DA TRIGGER NO DIR UTL
  */
  AARQUIVO  SYS.UTL_FILE.FILE_TYPE;
  CREATEARQ SYS.UTL_FILE.FILE_TYPE;
  SARQ    VARCHAR2(100) := '';
  SCAMINHO  VARCHAR2(100);
  CR      CHAR(1) := CHR(13);      
  AC      CHAR(1) := CHR(39);
  VS_CHV VARCHAR2(200);
  VSOWNER VARCHAR2(200);

BEGIN
  SCAMINHO := PDIRETORIO; -- '/oracle/arquivos/TT'; -- DIR UTL
  SARQ := 'TL_'||TRIM(PTABELA)||'.TXT';
  AARQUIVO := SYS.UTL_FILE.FOPEN(SCAMINHO,SARQ,'W');
  CREATEARQ := SYS.UTL_FILE.FOPEN(SCAMINHO,'TABELA_LOG.TXT','W');
  --BUSCAR O OWNER DO BANCO
  SELECT  Substr(Sys_Context('USERENV', 'CURRENT_USER'), 1, 250)
  INTO VSOWNER
   FROM DUAL;
   

   -- CRIA TABELA DE LOG
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'----------CREATE TABLE-----------'||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'Create Table TABELA_LOG (tabela   VARCHAR2(20), '||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'chave    VARCHAR2(20),'||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'usuario  VARCHAR2(20), '||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'data     DATE, '||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'conteudo VARCHAR2(4000), '||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'Vsuserbanco VARCHAR2(250), '||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'Vsterminal VARCHAR2(250), '||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'Vsmodulo VARCHAR2(250), '||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,'Vsaction VARCHAR2(250), '||CR);
  SYS.UTL_FILE.PUT_LINE(CREATEARQ,' Vsuserapp VARCHAR2(250)); '||CR);
  SYS.UTL_FILE.FCLOSE(CREATEARQ);

   
  
  -- BUSCAR A PRIMARY KEY DA TABELA
  FOR R IN (SELECT COLUMN_NAME
          FROM   USER_CONSTRAINTS , USER_CONS_COLUMNS
          WHERE  CONSTRAINT_TYPE = 'P'
          AND USER_CONS_COLUMNS.CONSTRAINT_NAME = USER_CONSTRAINTS.CONSTRAINT_NAME
        AND USER_CONSTRAINTS.TABLE_NAME = PTABELA
                                   ORDER BY POSITION )
  LOOP
  VS_CHV := VS_CHV || ':NEW.' || R.COLUMN_NAME || '||';
  END LOOP;
  VS_CHV := SUBSTR(VS_CHV,1,(LENGTH(VS_CHV)-2));
  --CRIA CABEÇALHO DA TRIGGER
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'CREATE OR REPLACE TRIGGER TL_'||PTABELA||'_LOG'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'AFTER UPDATE ON ' ||PTABELA||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'REFERENCING OLD AS OLD NEW AS NEW'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'FOR EACH ROW'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -----------------------------------------------------------------------------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -- TRIGGER PARA LOG DE ALTERACOES DA TABELA '||PTABELA||' --------------------------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -- CODIGO GERADO AUTOMATICAMENTE PELO PROGRAMA CRIA_TRIGGER_LOG -----------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -- CRIADO EM '|| TO_CHAR(SYSDATE,'DD/MM/YY') || ' -------------------------------------------------------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -----------------------------------------------------------------------------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'DECLARE'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  ------------------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  ---  VARIAVEIS ---'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  Vsuserbanco VARCHAR2(250);'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  Vsusermaq VARCHAR2(250);'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'   Vsterminal VARCHAR2(250);'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  Vsmodulo VARCHAR2(250);'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  Vsaction VARCHAR2(250);'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  Vsuserapp VARCHAR2(250);'||CR);  
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  V_OSUSER  VARCHAR2(50);'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  V_DATA    DATE := SYSDATE;'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  V_TABELA  VARCHAR2(20) := '||AC||PTABELA||AC||';'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  V_CHAVE  VARCHAR2(20);'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  V_CONTEUDO  VARCHAR2(4000);'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -----------------------------------------------------------------------------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'BEGIN'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -----------------------------------------------------------------------------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -----------------------------------------------------------------------------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,' --BUSCAR INFORMAÇÕES GERAIS DO USUARIO
      SELECT Substr(Sys_Context('||AC||'USERENV'||AC||', '||AC||'CURRENT_USER'||AC||'), 1, 250),
             Substr(Sys_Context('||AC||'USERENV'||AC||', '||AC||'OS_USER'||AC||'), 1, 250),
             Substr(Sys_Context('||AC||'USERENV'||AC||', '||AC||'TERMINAL'||AC||'), 1, 250),
             Substr(Sys_Context('||AC||'USERENV'||AC||', '||AC||'MODULE'||AC||'), 1, 250),
             Substr(Sys_Context('||AC||'USERENV'||AC||', '||AC||'ACTION'||AC||'), 1, 250),            
             Substr((SELECT MAX(a.C5_Userapp)
                     FROM Gex_C5client a), 1, 250) User_App

      INTO Vsuserbanco, Vsusermaq, Vsterminal, Vsmodulo, Vsaction, Vsuserapp
      FROM Dual;'||CR);
  
   
  
  --CRIAR CONDIÇÕES IF PARA ALTERAÇÃO COLUNAS OLD <> NEW
  FOR R IN (SELECT COLUMN_NAME COLUNA,
           '  IF (NVL(:OLD.'||TO_CHAR(COLUMN_NAME)||','||
             DECODE(DATA_TYPE,'VARCHAR2',
                    '0',
                    'NUMBER','-1',
                    'DATE','(SYSDATE-36500)')||') <> ' ||
             'NVL(:NEW.'||COLUMN_NAME||','||
             DECODE(DATA_TYPE,'VARCHAR2',
                    '0',
                    'NUMBER','-1',
                    'DATE','(SYSDATE-36500)')||')) THEN' LINHA1,
 (CASE WHEN DATA_TYPE LIKE '%CHAR%' THEN AC || TO_CHAR(COLUMN_NAME||' DE : ') ||AC|| '|| :OLD.'||TO_CHAR(COLUMN_NAME) || ' || ' ||
                             AC||  TO_CHAR(' PARA : ') ||AC|| '|| :NEW.'||COLUMN_NAME
                            ELSE  AC|| TO_CHAR(COLUMN_NAME||' DE : ') ||AC|| '|| TO_CHAR(' || ':OLD.'||TO_CHAR(COLUMN_NAME) || ') ||'  ||
                               AC||TO_CHAR(' PARA : ') ||AC|| '|| TO_CHAR(' || ':NEW.'||TO_CHAR(COLUMN_NAME) || ')' END) LINHA2
      FROM ALL_TAB_COLUMNS
       WHERE OWNER = VSOWNER
       AND   TABLE_NAME = PTABELA
       ORDER BY COLUMN_ID)
  LOOP
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -------> '||R.COLUNA||' '||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,R.LINHA1||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  V_CHAVE := '||VS_CHV||';'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  V_CONTEUDO := '||R.LINHA2||';'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  INSERT INTO TABELA_LOG (Tabela, Chave, Data, Conteudo, Vsuserbanco, Vsusermaq, Vsterminal,   Vsmodulo, Vsaction, Vsuserapp)
                                    VALUES (V_TABELA,V_CHAVE,V_DATA,V_CONTEUDO, Vsuserbanco, Vsusermaq, Vsterminal, Vsmodulo, Vsaction, Vsuserapp);'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  END IF;'||CR);
  END LOOP;
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'  -----------------------------------------------------------------------------'||CR);
  SYS.UTL_FILE.PUT_LINE(AARQUIVO,'END;'||CR);
  SYS.UTL_FILE.FCLOSE(AARQUIVO);
END CRIA_TRIGGER_LOG;
/
