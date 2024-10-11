.data
bem_vindo: .asciiz "Bem-vindo ao editor de texto MIPS\n"
buffer: .space 20
nome_arquivo: .asciiz "saida.txt"
mensagem_erro: .asciiz "Erro ao abrir o arquivo"
msg_buffer_cheio: .asciiz "\nErro: Buffer está cheio, encerrando programa..."

.text
#Mudanças a serem feitas:
#beq caso buffer fique cheio (Contador já foi feito {$t1, aumenta quando adiciona no buffer})
#mudar a tecla colchete para uma melhor (Ctrl + S ou relacionado)
#Implementar procedimento para apagar caractere
#{
#- Irá detectar a tecla backspace (~08)
#- Voltar células de memória/apagar (Carregar valor nulo)
#- Diminuir contador
#}
#Implementar procedimento para escolher o nome do arquivo
#Implementar procedimento para abrir um arquivo e edita-lo
#{
#- Escrever no buffer todo conteúdo do arquivo
#- Usar a mesma lógica de adição/remoção de caracteres
#- Usar o mesmo nome do arquivo para salvar(sobrescrever)
#}

#Legenda:
#$t0 == buffer
#$t1 == contador do buffer
#$t2 == caractere lido
#$t3 == ASCII de comparação (Colchete)
#$t4 == Descritor

# Inicialização do buffer + contador de caracteres
la $t0, buffer
li $t1, 0
li $t5, 50

#Syscall para imprimir a mensagem de bem-vindo
li $v0, 4
la $a0, bem_vindo
syscall

#Loop de entrada para o usuário digitar o texto
#Abaixo do procedimento "loop_entrada" fará um syscall para ler UM caractere do usuário
loop_entrada:
li $v0, 12
syscall
move $t2, $v0

beq $t1, $t5, buffer_cheio

#Guarda o ASCII para "Colchete" em $t3 e faz um branch se o usuário digitou Colchete
li $t3, 91
beq $t2, $t3, detectado_colchete

#Armazena o caractere em $t0(buffer), vai para a próxima célula de memória e aumenta o contador
sb $t2, 0($t0)
addi $t0, $t0, 1
addi $t1, $t1, 1
j loop_entrada

#Se for detectado Colchete, grava o conteúdo do buffer em um arquivo de saída.
detectado_colchete:
li $v0, 13
la $a0, nome_arquivo
li $a1, 1
syscall

buffer_cheio:
li $v0, 4
la $a0, msg_buffer_cheio
syscall
j finalizar_programa

#Erro ao abrir o arquivo
blt $v0, 0, erro

#Guarda o descritor do arquivo em $t4
move $t4, $v0

#Syscall para escrita em um arquivo
li $v0, 15
move $a0, $t4
la $a1, buffer
move $a2, $t1
syscall

#Fechar o arquivo
li $v0, 16
move $a0, $t4
syscall      

j finalizar_programa

erro:
# Caso de erro ao abrir o arquivo
li $v0, 4
la $a0, mensagem_erro
syscall

finalizar_programa:
#Finalizar o programa
li $v0, 10
syscall