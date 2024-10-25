.data
msg_bem_vindo: .asciiz "Bem-vindo ao editor de texto MIPS - Use ':' para salvar o arquivo\n"
msg_buffer_cheio: .asciiz "\nErro: Buffer está cheio\n"
msg_erro: .asciiz "\nErro ao abrir o arquivo"
msg_comandos: .asciiz "\nSalvar - s | Cancelar - (qualquer tecla)\n"
msg_arquivo: .asciiz "\nDigite o nome o arquivo + extensão - Confirme com ':'\n"
msg_cancelar: .asciiz "\nOperação cancelada\n"
buffer: .space 50 #Caso queira alterar o tamanho do buffer, terá que alterar o limite do contador também
nome_arquivo: .space 256

.text
#Mudanças a serem feitas:
#Implementar procedimento para apagar caractere.
#{
#- Irá detectar a tecla backspace (~08).
#- Voltar células de memória/apagar (Carregar valor nulo).
#- Diminuir contador.
#}
#Implementar procedimento para abrir um arquivo e edita-lo.
#{
#- Escrever no buffer todo conteúdo do arquivo.
#- Usar a mesma lógica de adição/remoção de caracteres.
#- Usar o mesmo nome do arquivo para salvar(sobrescrever).
#}

#Legenda:
#$t0 == buffer
#$t1 == contador do buffer
#$t2 == caractere lido (Uso Geral)
#$t3 == Descritor
#$t4 == buffer nome do arquivo

# Inicialização dos buffers + contador de caracteres.
la $t0, buffer
la $t4, nome_arquivo
li $t1, 0

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

#Verifica se a entrada do usuário é "Hífen" (ASCII - 45 -> "-");
beq $t2, 45, backspace

#Verifica se a entrada do usuário ($t2) é igual a ":"(ASCII - 58).
beq $t2, 58, detectado_dois_pontos

#Verifica se o buffer está cheio - Contador ($t1) - Máximo Caracteres (50)
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

#Verifica se o usuário digitou "s" após ":" para Salvar o arquivo.
beq $t2, 115, salvar_arquivo

#Caso contrário, pula novamente para o loop de entrada.
li $v0, 4
la $a0, msg_cancelar
syscall
j loop_entrada

salvar_arquivo:
#Imprime para o usuário digitar o nome do arquivo.
li $v0, 4
la $a0, msg_arquivo
syscall

#Leitura do nome do arquivo
loop_entrada_arquivo:
li $v0, 12
syscall
move $t2, $v0

#Verifica se a entrada do usuário ($t2) é igual a ":"(ASCII - 58).
beq $t2, 58, detectado_dois_pontos_arquivo

#Armazena o caractere em $t4(buffer de arquivo), vai para a próxima célula de memória.
sb $t2, 0($t4)
addi $t4, $t4, 1

j loop_entrada_arquivo

detectado_dois_pontos_arquivo:
#Abre o arquivo
li $v0, 13
la $a0, nome_arquivo
li $a1, 1
syscall

#Erro ao abrir o arquivo
blt $v0, 0, erro

#Guarda o descritor do arquivo em $t3
move $t3, $v0

#Syscall para escrita em um arquivo
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