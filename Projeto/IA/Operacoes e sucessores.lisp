;;
;;
;;TODO: CRIAR UMA HASH TABLE E GERAR CONHECIMENTO PREENCHER
;;TODO: TER EM CONTA A SIMETRIA DO TABULEIRO ATRAVÉS DAS 4 PERSPETIVAS
;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Metodos do tabuleiro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun get-arcos-horizontais (tabuleiro)
	"Retorna a lista dos arcos horizontais de um tabuleiro"
	(first tabuleiro) ; devolve o primeiro elemento do tabuleiro
)

(defun get-arcos-verticais (tabuleiro)
	"Retorna a lista dos arcos verticiais de um tabuleiro"
	(second tabuleiro) ; devolve o segundo elemento do tabuleiro
)

(defun arco-na-posicao (i lista peca)
	"Recebe uma lista de arcos e tenta inserir um arco na posição i"
	(let
		(
			(elemento (elemento-por-indice (1- i) lista))
		)
		(cond
			((null elemento) (substituir (1- i) peca lista))
			(t nil)
		)
	)
)

(defun arco-aux (x y matriz peca)
	"Recebe uma matriz de arcos e tenta inserir um arco na posição x y"
	(let*
		(
			(x-aux (1- x)) ; altera a indexação do x para x-1
			(lista (elemento-por-indice x-aux matriz)) ;vai buscar a lista a matriz na posição x-1
			(nova-lista (arco-na-posicao y lista peca)) ; mete o arco na posição
		)
		(cond
			((null nova-lista) nil) ; se devolveu nil devolve nil
			(T (substituir x-aux nova-lista matriz)) ; caso contrário substitui a lista
		)
	)
)

(defun arco-horizontal (x y tabuleiro peca)
	"Recebe um tabuleiro e tenta inserir um arco na posição x y dos arcos horizontais"
	(let*
		(
			(arcos-horizontais (get-arcos-horizontais tabuleiro)) ; vai buscar a matriz de arcos horizontais ao tabuleiro
			(arcos-horizontais-resultado (arco-aux x y arcos-horizontais peca)) ; mete o arco na posição x e y da matriz
		)
		(cond
			((null arcos-horizontais-resultado) nil) ; se devolveu nil devolve nil
			(t (substituir 0 arcos-horizontais-resultado tabuleiro)) ; caso contrário substitui a matriz nos arcos horizontais do tabuleiro
		)
	)
)


(defun arco-vertical (x y tabuleiro peca)
	"Recebe um tabuleiro e tenta inserir um arco na posição x y dos arcos verticais"
	(let*
		(
			(arcos-verticais (get-arcos-verticais tabuleiro)) ; vai buscar a matriz de arcos verticais ao tabuleiro
			(arcos-verticais-resultado (arco-aux x y arcos-verticais peca)) ; mete o arco na posição x e y da matriz
		)
		(cond
			( (null arcos-verticais-resultado) nil) ; se devolveu nil devolve nil
			( t (substituir 1 arcos-verticais-resultado tabuleiro) ) ; caso contrário substitui a matriz nos arcos verticais do tabuleiro
		)
	)
)

(defun numero-caixas-horizontal (tabuleiro)
	"Dá número de caixas na horizontal"
	(length (first (get-arcos-horizontais tabuleiro)))
)

(defun numero-caixas-vertical (tabuleiro)
	"Dá número de caixas na vertical"
	(length (first (get-arcos-verticais tabuleiro)))
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Simetrias
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun rodar90 (tabuleiro)
	(let*
		(
			(horizontais (get-arcos-horizontais tabuleiro))
			(verticais (get-arcos-verticais tabuleiro))
			(novo-horizontais
				(mapcar 'reverse verticais)
			)
			(novo-verticais
				(reverse horizontais)
			)
		)
		(list novo-horizontais novo-verticais)
	)
)

(defun espelhar-horizontal (tabuleiro)
	(let*
		(
			(horizontais (get-arcos-horizontais tabuleiro))
			(verticais (get-arcos-verticais tabuleiro))
			(novo-horizontais
				(mapcar 'reverse horizontais)
			)
			(novo-verticais
				(reverse  verticais)
			)
		)
		(list novo-horizontais novo-verticais)
	)
)


(defun espelhar-vertical (tabuleiro)
	(let*
		(
			(horizontais (get-arcos-horizontais tabuleiro))
			(verticais (get-arcos-verticais tabuleiro))
			(novo-horizontais
				(reverse horizontais)
			)
			(novo-verticais
				(mapcar 'reverse verticais)
			)
		)
		(list novo-horizontais novo-verticais)
	)
)












;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Operadores
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun criar-operacao (x y funcao nome-funcao)
	"Cria uma fun??o lambda que representa uma opera??o atrav?s de uma opera??o (arco-horizontal/arco-vertical) e a posi??o x e y"
	(lambda (no) ; operador
		(let*
			(
				( peca (no-jogador no))
				( numero-caixas (+ (no-numero-caixas-jogador1 no) (no-numero-caixas-jogador2 no)) )
				( tabuleiro (funcall funcao x y (no-estado no) peca) ) ;executa a opera??o sobre o no
			)
			(cond
				((null tabuleiro) nil)
				((equal (no-estado no) tabuleiro) nil) ; se o estado do antecessor ? igual ao estado do sucessor, ? discartando devolvendo nil
				(t
					(let*
						(
							(no-resultado 	(set-no-numero-arestas (set-no-jogada ;altera a jogada do nó
																		(set-no-profundidade  ;altera a profundidade do n?
																			(set-no-pai ;altera a pai do n? antecessor devolvendo um novo n?
																					(set-no-estado no tabuleiro) ; altera o estado do nó pai
																					no ; nó pai
																			)
																			(1+ (no-profundidade no));altera a profundidade do n?
																		)
																		(list funcao nome-funcao x y)
																)
																(cond
																	((null (no-numero-arestas no)) (1+(n-arestas-preenchidas (no-estado no))))
																	( t (1+ (no-numero-arestas no)) )
																)
											)
							)
							(no-numero-caixas (numero-caixas-fechadas tabuleiro))
						)
						(cond
							((= no-numero-caixas numero-caixas) (set-no-jogador no-resultado (trocar-peca peca)));numero de caixas não mudou
							((= peca *jogador1*) (set-no-numero-caixas-jogador1 no-resultado (1+ (no-numero-caixas-jogador1 no-resultado))));incrementa o numero de caixas do jogador
							((= peca *jogador2*) (set-no-numero-caixas-jogador2 no-resultado (1+ (no-numero-caixas-jogador2 no-resultado))));incrementa o numero de caixas do jogador
						)
					)
				)
			)
		)
	)
)



;; N?o existe grande peso de performance aqui pois as opera??es s?o geradas apenas no ?nicio

(defun criar-operacoes-decrementarY (x y funcao nome-funcao)
	"Decrementa o valor de y recursivamente e vai criando opera??es com o valor de x e y e a fun??o"
	(cond
		( (= y 0) nil ) ; se y igual a 0 devolve nil
		( t (cons (criar-operacao x y funcao nome-funcao) (criar-operacoes-decrementarY x (1- y) funcao nome-funcao)) ) ; cria a opera??o para x e y e chama recusivamente a fun??o com y-1
	)
)


(defun criar-operacoes-decrementarX (x y funcao nome-funcao)
	"Decrementa o valor de x recursivamente e vai chamando a fun??o 'criar-operacoes-decrementarY' com o valor de x e y e a funcao"
	(cond
		( (= x 0) nil ) ; se x igual a 0 devolve nil
		( t (append (criar-operacoes-decrementarY x y funcao nome-funcao) (criar-operacoes-decrementarX (1- x) y funcao nome-funcao)) ) ; chama a fun??o que cria as opera??es decrementando y para x e come?ando em y e chama recusivamente a fun??o com x-1
	)
)


(defun criar-operacoes (n m funcao-verticais funcao-horizontais)
	"Gera todos os operadores poss?veis para um tabuleiro de n por m"
	(append
		(criar-operacoes-decrementarX (1+ n) m funcao-horizontais "arco-horizontal") ; chama a fun??o que cria as opera??es decrementando x partindo de x = (n+1) e y = m
		(criar-operacoes-decrementarX (1+ m) n funcao-verticais "arco-vertical") ; chama a fun??o que cria as opera??es decrementando x partindo de x = (m+1) e y = n
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Testes para as operações
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun aplicar-consecutivamente (no operacoes)
	"Aplica um conjunto de operações consecutivas a um tabuleiro"
	(cond
		( (null operacoes) no )
		( t (aplicar-consecutivamente (funcall (first operacoes) no) (rest operacoes)) )
	)
)

; (teste-preencher 7 7 *jogador1*)
(defun teste-preencher (n m peca)
	"Realiza um teste que gera todos os operadores possiveis e os aplica num tabuleiro n por m consecutivo, com objetivo a preecher todo o tabuleiro com arcos"
	(let
		(
			(operacoes (criar-operacoes n m #'arco-vertical #'arco-horizontal))
			(tabuleiro (tabuleiro-inicial))
		)
		(aplicar-consecutivamente (no-criar tabuleiro nil 0 (list 0 0 peca)) operacoes)
	)
)


;; avaliar-folha

;Defina uma fun??o avaliar-folha que recebe um n? final (validado anteriormente
;pela fun??o vencedor-p) e o tipo de jogador [MAX ; MIN]. A fun??o retorna o valor [100] em
;caso de vitoria do jogador MAX, o valor [-100] em caso de vitoria do jogador MIN ou o valor [0]
;em caso de empate.
(defun avaliar-folha (no)
	""
	(let
		(
			(vencedor (vencedor-p (no-numero-caixas-jogador1 no) (no-numero-caixas-jogador2 no)))
		)
		(cond
			((= vencedor (trocar-peca (no-jogador no))) 100)
			((= vencedor nil) 0)
			(t -100)
		)
	)
)



;; avaliar-folha-limite

(defun avaliar-folha-limite (no jogador-otimizar)
""
(let*
	(
		(tabuleiro (no-estado no))
		(tabuleiro-pai (no-estado (no-pai no)))
		(jogador (no-jogador no))
		(numero-caixas (cond
							((= jogador *jogador1*) (no-numero-caixas-jogador1 no))
							(t (no-numero-caixas-jogador2 no)))
		)
		(numero-caixas-adversario (cond
							((= jogador *jogador1*) (no-numero-caixas-jogador2 no))
							(t (no-numero-caixas-jogador1 no)))
		)
		(numero-arestas (no-numero-arestas no))
 		(resultado 	(f-avaliacao  tabuleiro tabuleiro-pai jogador numero-caixas numero-caixas-adversario numero-arestas))
	)
	(cond
						((= jogador jogador-otimizar) resultado)
						(t -resultado ))
)


)




(defun remover-sucessores(tabuleiro sucessores)
	"Remove todas a ocorrencias de um tabuleiro nos sucessores"
	(cond
		( (null sucessores) nil )
		( (equal tabuleiro (no-estado (first sucessores))) (remover-sucessores tabuleiro (rest sucessores)) )
		( t (cons (first sucessores) (remover-sucessores tabuleiro (rest sucessores))) )
	)
)


(defun sucessores-sem-simetrias(sucessores)
	"Remove os sucessores simétricos deixando apenas nós com tabuleiros únicos conceptualmente"
	(cond
		((null sucessores) nil)
		(t (let*
				(
				(normal (no-estado (first sucessores)))
				(n-esp-h (espelhar-horizontal normal))
				(n-esp-v (espelhar-vertical normal))
				(rodado90 (rodar90 normal))
				(rodado90-esp-h (espelhar-horizontal rodado90))
				(rodado90-esp-v (espelhar-vertical rodado90))
				(rodado180 (rodar90 rodado90))
				(rodado270 (rodar90 rodado180))

				(s1 (remover-sucessores normal (rest sucessores)))
				(s2 (remover-sucessores rodado90 s1))
				(s3 (remover-sucessores rodado180 s2))
				(s4 (remover-sucessores rodado270 s3))
				(s5 (remover-sucessores n-esp-h s4))
				(s6 (remover-sucessores n-esp-v s5))
				(s7 (remover-sucessores rodado90-esp-h s6))
				(s8 (remover-sucessores rodado90-esp-v s7))
				)
				(cons (first sucessores) (sucessores-sem-simetrias s8))
			)
		)
	)
)

;; sucessores-no
;Defina uma fun??o sucessores-no que recebe 1) um n?, 2) a indica??o do s?mbolo usado
;pelo jogador m?quina [1 ; 2] e 3) dois valores inteiros que representam respetivamente o
;n?mero de caixas fechadas pelo jogador 1 e o n?mero de caixas fechadas pelo jogador 2.
;A fun??o retorna a lista dos sucessores do tabuleiro para o tipo de s?mbolo recebido por
;par?metro. Numa fase mais adiantada do desenvolvimento, esta fun??o poder? receber
;outros par?metros, tal como a profundidade limite de expans?o da ?rvore do jogo.

; TODO - GUARDAR OS SUCESSORES GERADOS NUMA HASH TABLE
(defun sucessores-no (no operadores)
	""
	(let*
		(
			(funcao (lambda (op) ;função que irá gerar os nós sucessores para cada operação
							(funcall op no)
					)
			)
			(sucessores (limpar-nils (mapcar funcao operadores)))
		)
		(cond
			((> (no-numero-arestas no) 20)  (sucessores-sem-simetrias sucessores)) ; optimizações de simetria até 20 arestas
			(t sucessores)
		)
	)
)
;(sucessores-no (no-criar (tabuleiro-inicial) nil 0 (list 0 0 *jogador1*)) (criar-operacoes 7 7 #'arco-vertical #'arco-horizontal))
;(sucessores-no (no-criar '(((0 0)(0 0)(0 0))((0 0)(0 0)(0 0))) nil 0 (list 0 0 *jogador1*)) (criar-operacoes 2 2 #'arco-vertical #'arco-horizontal))



(defun ordenar-crescente (sucessores)
	(sort (mapcar 'avaliar-folha-limite sucessores) #'< )
)

(defun ordenar-decrescente (sucessores)
	(sort (mapcar 'avaliar-folha-limite sucessores) #'> )
)
