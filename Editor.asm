.data
msg_bem_vindo: .asciiz "Bem-vindo ao editor de texto MIPS - Use ':' para salvar o arquivo\n"
msg_buffer_cheio: .asciiz "\nErro: Buffer está cheio\n"
msg_erro: .asciiz "\nErro ao abrir o arquivo"
msg_comandos: .asciiz "\nSalvar - s | Cancelar - (qualquer tecla)\n"
msg_arquivo: .asciiz "\nDigite o nome o arquivo + extensão - Confirme com 'Enter'\n"
msg_cancelar: .asciiz "\nOperação cancelada\n"
quebra_linha: .asciiz "\n"
buffer: .space 50 #Caso queira alterar o tamanho do buffer, terá que alterar o limite do contador também
nome_arquivo: .space 256

.text
#Legenda:
#$t0 == buffer
#$t1 == contador do buffer
#$t2 == caractere lido (Uso Geral)
#$t3 == Descritor
#$t4 == buffer nome do arquivo
#$t5 == Caractere nulo
#$t6 == Flag para salvar/editar

# Inicialização dos buffers + contador de caracteres + flag.
la $t0, buffer
la $t4, nome_arquivo
li $t1, 0
li $t6, 0
#Syscall para imprimir a mensagem de bem-vindo.
li $v0, 4
la $a0, msg_bem_vindo
syscall

#Loop de entrada para o usuário digitar o texto.
#==========================================================================================
#"loop_entrada" fará um syscall para ler UM caractere do usuário.
loop_entrada:
li $v0, 12
syscall
move $t2, $v0

#Verifica se a entrada do usuário é "-" (ASCII - 45).
beq $t2, 45, apagar

#Verifica se a entrada do usuário é ":"(ASCII - 58).
beq $t2, 58, detectado_dois_pontos

#Verifica se o buffer está cheio - Contador ($t1) - Máximo Caracteres (50).
bne $t1, 50, continuacao

#Imprime mensagem que o buffer está cheio e volta para o loop de entrada.
li $v0, 4
la $a0, msg_buffer_cheio
syscall
j loop_entrada

continuacao:
#Armazena o caractere em $t0(buffer), vai para a próxima célula de memória e aumenta o contador.
sb $t2, 0($t0)
addi $t0, $t0, 1
addi $t1, $t1, 1
j loop_entrada

# Função para apagar
apagar:
# Verifica se o buffer não está vazio
beq $t1, 0, tratar_apagar

# Decrementa o contador e ajusta o ponteiro do buffer para apagar o último caractere
li $t5, 0
sb $t5, 0($t0)
addi $t1, $t1, -1
addi $t0, $t0, -1
sb $t5, 0($t0)

tratar_apagar:
li $v0, 4
la $a0, quebra_linha
syscall

li $v0, 4
la $a0, buffer
syscall

j loop_entrada
#==========================================================================================

#Salvar o texto em um arquivo
#==========================================================================================
#Se for detectado "dois pontos", abre a parte de comandos.
detectado_dois_pontos:
li $v0, 4
la $a0, msg_comandos
syscall

#Lê um caractere do usuário
li $v0, 12
syscall
move $t2, $v0

#Verifica se o usuário digitou "s/S" após ":" para Salvar o arquivo.
beq $t2, 115, salvar_arquivo
beq $t2, 83, salvar_arquivo

#Verifica se o usuário digitou "e/E" após ":" para editar o arquivo.
beq $t2, 101, editar_arquivo
beq $t2, 69, editar_arquivo

#Verifica se o usuário digitou "c/C" após ":" para editar o arquivo.
beq $t2, 99, cancelar
beq $t2, 67, cancelar

j detectado_dois_pontos

cancelar:
li $v0, 4
la $a0, msg_cancelar
syscall
j loop_entrada

editar_arquivo:
li $t6, 1 #1 para o flag de escrita
li $t1, 0

salvar_arquivo:
beq $t6, 2, escrita_arquivo
#Imprime para o usuário digitar o nome do arquivo.
li $v0, 4
la $a0, msg_arquivo
syscall

#Leitura do nome do arquivo
loop_entrada_arquivo:
li $v0, 12
syscall
move $t2, $v0

#Verifica se a entrada do usuário ($t2) é igual a "Enter"(ASCII - 10).
beq $t2, 10, detectado_enter

#Armazena o caractere em $t4(buffer de arquivo), vai para a próxima célula de memória.
sb $t2, 0($t4)
addi $t4, $t4, 1

j loop_entrada_arquivo

detectado_enter:
beq $t6, 0, escrita_arquivo
#Abre o arquivo
li $v0, 13
la $a0, nome_arquivo
li $a1, 0 #Leitura
syscall

#Erro ao abrir o arquivo
blt $v0, 0, erro

#Guarda o descritor do arquivo em $t3
move $t3, $v0

#Syscall para edição do arquivo:
contar_caractere:
li $v0, 14
move $a0, $t3
la $a1, buffer
li $a2, 1
syscall

bgt $v0, 0, leu_caractere
j terminada_contagem

leu_caractere:
addi $t1, $t1, 1
addi $t0, $t0, 1
j contar_caractere

terminada_contagem:
li $v0, 16
move $a0, $t3
syscall

li $v0, 13
la $a0, nome_arquivo
li $a1, 0 #Leitura
syscall
move $t3, $v0

li $v0, 14
move $a0, $t3
la $a1, buffer
move $a2, $t1
syscall

li $v0, 16
move $a0, $t3
syscall

li $t6, 2

li $v0, 4
la $a0, buffer
syscall
j loop_entrada

escrita_arquivo:
li $v0, 13
la $a0, nome_arquivo
li $a1, 1 #Escrita
syscall
move $t3, $v0

blt $v0, 0, erro

li $v0, 4
la $a0, buffer
syscall

li $v0, 1
move $a0, $t1
syscall

li $v0, 15
move $a0, $t3
la $a1, buffer
move $a2, $t1
syscall

#Fechar o arquivo
li $v0, 16
move $a0, $t3
syscall
j finalizar_programa

erro:
# Caso de erro ao abrir o arquivo
li $v0, 4
la $a0, msg_erro
syscall

finalizar_programa:
#Finalizar o programa
li $v0, 10
syscall
#==========================================================================================
