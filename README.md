Este repositório contém os ficheiros para instalar o [Magento](https://developer.adobe.com/open/magento) num _container_ _Docker_.
O Magento é uma aplicação feita em PHP e necessita de um conjunto de software (servidor web, base de dados, serviço de pesquisa, serviço de mensages, ...), tal como apresentado na página que apresenta uma [visão geral do processo de instalação](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/overview.html).  Os [requisitos do sistema](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/system-requirements.html) contêm informação mais detalhada, em particular o número de versão do software necessário.

As instruções neste repositório foram baseadas nas páginas (por ordem decrescente de relevância):

1. [https://www.mgt-commerce.com/tutorial/how-to-install-magento-2-4-4-on-ubuntu-20-04](https://www.mgt-commerce.com/tutorial/how-to-install-magento-2-4-4-on-ubuntu-20-04/) Contém instruções para instalar o magento e software necessário numa única máquina.
2. [https://www.mgt-commerce.com/tutorial/how-to-install-magento-2-4-4-on-debian-11](https://www.mgt-commerce.com/tutorial/how-to-install-magento-2-4-4-on-debian-11/) Tal como o anterior, é um tutorial para instalar o magento e demais software numa única máquina.
3. [https://experienceleague.adobe.com/docs/commerce-operations/installation-guide](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/overview.html) Contém instruções para instalar o magento em máquinas geridas por nós.

## Container Docker

Foi utilizado o _Docker compose_ para criar um serviço, três volumes e uma rede:

	version: '3'
	services:
	  ai4pa_2:
	    build:
	      context: .
	      dockerfile: Dockerfile
	    container_name: ai4pa-ALL
	    volumes:
	      - "ai4pa-www:/var/www/"
	      - "ai4pa-magento:/root/"
	      - "ai4pa-db:/var/lib/mysql/"
	    networks:
	      - ai4pa-network
	    ports:
	      - 80:80
	      - 8082:8082
	
	volumes:
	  ai4pa-www:
	  ai4pa-magento:
	  ai4pa-db:
	
	networks:
	  ai4pa-network:

O serviço é baseado na distribuição Ubuntu _kinetic_. O ponto de partida do _container_ é `FROM "ubuntu:kinetic"`.  O ficheiro `Dockerfile` tem uma série de passos para construir o servico:

1. No primeiro passo são instalados algumas ferramentas usadas na construção do serviço e configurado o tempo local.  É também criada o diretório `docker-image` onde vai ser colocado o script executado no arranque do _container_.
2. No segundo passo é instalada o pacote padrão apache2, que no caso da distribuição _kinetic_ corresponde à versão 2.4.54.  É copiado o ficheiro [`magento-site.conf`](magento-site.conf) que contém as configurações apache para o magento.
3. No passo seguinte, é instalado o pacote padrão php (versão 8.1.7) e as extensões de que o magento depende.  São feitas algumas alterações à configuração do php para que a instalação do magento corra com sucesso.  A alteração principal diz respeito à quantidade de memória necessário: o padrão (128M) é insuficiente; o limite é alterado para 512M `RUN sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.1/apache2/php.ini`.
4. No quarto passo, é instalado o mysql (versão 8.0.32).  É copiado o ficheiro `setup.sql`, que contém as instruções para criar a base de dados utilizada pelo magento, para o diretório `docker-image`.
5. No passo seguinte, é instalado o serviço de pesquisa elasticsearch que está no repositório `artifacts.elastic.co`, pois a distribuição _kinetic_ não tem nenhum dos serviços de pesquisa que o magento depende.
6. No sexto passo, é instalado o composer, uma ferramenta de gestão de projetos php.
7. No passo número sete, é copiado o ficheiro `composer-auth.json` que tem as credenciais de acesso ao repositório magento.  As credenciais podem ser obtidas no [Marketplace](https://marketplace.magento.com/). Ir ao perfil do utilizador e clicar em _Access Keys_.  Na página [https://marketplace.magento.com/customer/accessKeys](https://marketplace.magento.com/customer/accessKeys/) é possível criar e visualizar as credenciais.
8. No penúltimo passo são instaladas algumas aplicações usadas para testar o magento: browser lynx e editor emacs.
9. O último passo consiste na cópia do script executado no arranque do container.

## Credenciais de Acesso ao Repositório Magento

É necessário alterar o conteúdo do ficheiro `composer-auth.json` e colocar as credenciais de acesso ao repositório magento.  Este repositório contém as diferentes versões do magento e vários módulos. 

Para criar as credenciais de acesso:

1. Entrar no site [Marketplace](https://marketplace.magento.com/) (registar caso não tenha uma conta).
2. Clicar no nome da conta (no topo direito da página) e selecionar a opção _My Profile_.
3. Clicar em _Access Keys_ na aba _Marketplace_ ![](https://experienceleague.adobe.com/docs/commerce-operations/assets/cloud_access-key.png?lang=en)
4. Clicar  _Create a New Access Key_. Introduzir o nome das chaves e clicar Ok.
5. As chaves pública e private aparecem ao lado do seu nome. Utilizar a chave pública como o username e a chave privada como a senha.

Exemplo do ficheiro composer-auth.json:

	{
	    "http-basic": {
	        "repo.magento.com": {
	            "username": "90dj8as CHAVE PÚBLICA alkn8ajhdm",
	            "password": "asd5jha CHAVE PRIVADA daun8ashjs"
	        }
	    }
	}

## Instalação do Magento

O magento é instalado no diretório `/var/www/html/magento2.4.5-p1`. Está instalado debaixo `/var/www/html/` porque é suposto apache servir os ficheiros php.  Os dois tutoriais presentes em [www.mgt-commerce.com](https://www.mgt-commerce.com) sugerem outras localizações, `/opt/magento2` e `/var/www/magento2` para ubuntu e debian, respectivamente.

A raiz dos documentos apache é `/var/www/html/magento2.4.5-p1/pub` tal como está especificado no ficheiro [`magento-site.conf`](magento-site.conf).

O script `mais-uma-volta.sh` apaga todos os _containers_ e apaga os volumes criados pelo _Docker_ compose. De seguida constroi o _container_ e finalmente corre o bash.  Assim é possível testar o script de arranque do _container_.

Em alternativa, executar `docker-compose up`.


## Site Magento

Todas as três instruções dizem que é possível abrir um browser em, por exemplo, `localhost`, e ver a página de entrada do magento:
![x](https://www.mgt-commerce.com/astatic/assets/images/article/2022/127/9002a3019b6b97550bfcdf8ceb159dd0.png)

No entanto, quando abro a página `localhost` (assumindo que na máquina local o porto 80 está ocupado pelo _Docker container_), aparece uma mensagem a dizer que ocorreu um erro no lado servidor.  O magento tem um diretório `var/log` onde são guardados as mensagens de erro.  O erro registado no ficheiro `/var/www/html/magento2.4.5-p1/var/log/system.log` é:

	2023-03-15T16:50:14.912626+00:00] main.ERROR: SQLSTATE[HY000] [2002] Permission denied [] []
	[2023-03-15T16:50:14.913747+00:00] main.CRITICAL: PDOException: SQLSTATE[HY000] [2002] Permission denied in /var/www/html/magento2.4.5-p1/vendor/magento/zendframework1/library/Zend/Db/Adapter/Pdo/Abstract.php:1\
	28
	Stack trace:
	#0 /var/www/html/magento2.4.5-p1/vendor/magento/zendframework1/library/Zend/Db/Adapter/Pdo/Abstract.php(128): PDO->__construct()
	#1 /var/www/html/magento2.4.5-p1/vendor/magento/zendframework1/library/Zend/Db/Adapter/Pdo/Mysql.php(111): Zend_Db_Adapter_Pdo_Abstract->_connect()
	#2 /var/www/html/magento2.4.5-p1/vendor/magento/framework/DB/Adapter/Pdo/Mysql.php(428): Zend_Db_Adapter_Pdo_Mysql->_connect()
	#3 /var/www/html/magento2.4.5-p1/vendor/magento/zendframework1/library/Zend/Db/Adapter/Abstract.php(460): Magento\Framework\DB\Adapter\Pdo\Mysql->_connect()
	#4 /var/www/html/magento2.4.5-p1/vendor/magento/zendframework1/library/Zend/Db/Adapter/Pdo/Abstract.php(238): Zend_Db_Adapter_Abstract->query()
	#5 /var/www/html/magento2.4.5-p1/vendor/magento/framework/DB/Adapter/Pdo/Mysql.php(564): Zend_Db_Adapter_Pdo_Abstract->query()
	#6 /var/www/html/magento2.4.5-p1/vendor/magento/framework/DB/Adapter/Pdo/Mysql.php(634): Magento\Framework\DB\Adapter\Pdo\Mysql->_query()
	#7 /var/www/html/magento2.4.5-p1/generated/code/Magento/Framework/DB/Adapter/Pdo/Mysql/Interceptor.php(95): Magento\Framework\DB\Adapter\Pdo\Mysql->query()
	#8 /var/www/html/magento2.4.5-p1/vendor/magento/framework/Lock/Backend/Database.php(84): Magento\Framework\DB\Adapter\Pdo\Mysql\Interceptor->query()
	#9 /var/www/html/magento2.4.5-p1/vendor/magento/framework/Lock/Proxy.php(56): Magento\Framework\Lock\Backend\Database->lock()
	#10 /var/www/html/magento2.4.5-p1/vendor/magento/framework/Cache/LockGuardedCacheLoader.php(134): Magento\Framework\Lock\Proxy->lock()
	#11 /var/www/html/magento2.4.5-p1/vendor/magento/module-config/App/Config/Type/System.php(281): Magento\Framework\Cache\LockGuardedCacheLoader->lockedLoadData()
	#12 /var/www/html/magento2.4.5-p1/vendor/magento/module-config/App/Config/Type/System.php(207): Magento\Config\App\Config\Type\System->loadDefaultScopeData()
	#13 /var/www/html/magento2.4.5-p1/vendor/magento/module-config/App/Config/Type/System.php(181): Magento\Config\App\Config\Type\System->getWithParts()
	#14 /var/www/html/magento2.4.5-p1/vendor/magento/framework/App/Config.php(132): Magento\Config\App\Config\Type\System->get()
	#15 /var/www/html/magento2.4.5-p1/vendor/magento/framework/App/Config.php(80): Magento\Framework\App\Config->get()
	#16 /var/www/html/magento2.4.5-p1/vendor/magento/framework/App/Config.php(93): Magento\Framework\App\Config->getValue()
	#17 /var/www/html/magento2.4.5-p1/vendor/magento/module-new-relic-reporting/Model/Config.php(94): Magento\Framework\App\Config->isSetFlag()
	#18 /var/www/html/magento2.4.5-p1/vendor/magento/module-new-relic-reporting/Plugin/HttpPlugin.php(49): Magento\NewRelicReporting\Model\Config->isNewRelicEnabled()
	#19 /var/www/html/magento2.4.5-p1/vendor/magento/framework/Interception/Interceptor.php(121): Magento\NewRelicReporting\Plugin\HttpPlugin->beforeCatchException()
	#20 /var/www/html/magento2.4.5-p1/vendor/magento/framework/Interception/Interceptor.php(153): Magento\Framework\App\Http\Interceptor->Magento\Framework\Interception\{closure}()
	#21 /var/www/html/magento2.4.5-p1/generated/code/Magento/Framework/App/Http/Interceptor.php(32): Magento\Framework\App\Http\Interceptor->___callPlugins()
	#22 /var/www/html/magento2.4.5-p1/vendor/magento/framework/App/Bootstrap.php(270): Magento\Framework\App\Http\Interceptor->catchException()
	#23 /var/www/html/magento2.4.5-p1/pub/index.php(30): Magento\Framework\App\Bootstrap->run()
	#24 {main}

Este _trace_ refere uma ligação ao mysql que aparenta ter falhado. No entanto, na linha comando consigo ligar ao servidor `mysql` (utilizando as credenciais presentes no ficheiro `setup.sql`).

Na pasta `phpserver` existe um ficheiro `README.md` com um exemplo de como correr o Magento. O comando é:

```shell
php -S 127.0.0.1:8082 -t ./pub/ ./phpserver/router.php
```

Este comando não menciona o apache.  Dentro do _container_ consigo ver uma página.  Fora do container, com redirecionamento, nada aparece.  Se entrar no _container_ e correr o comando `lynx localhost:8082` aparece uma página em modo texto. Este texto é semelhante ao conteúdo presente na imagem no início desta secção.  Se navegar em algum dos link, aparece uma mensagem de erro.

O `lynx` é um browser que corre no terminal.  Apresenta as páginas HTML só em modo texto.

