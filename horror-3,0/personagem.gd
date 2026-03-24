extends CharacterBody2D

# --- VARIÁVEIS EXPORTADAS ---
# Estas aparecem no Inspetor do Godot para você ajustar facilmente.

# Velocidade máxima de caminhada (pixels por segundo)
@export var max_speed: float = 250.0

# Quão rápido o personagem acelera (0.0 a 1.0)
# 1.0 = aceleração instantânea, 0.1 = muito lento e "escorregadio"
@export var acceleration_factor: float = 0.2

# Quão rápido o personagem desacelera quando você solta o botão
@export var friction_factor: float = 0.25

# --- VARIÁVEIS INTERNAS ---
var input_direction: Vector2 = Vector2.ZERO

# --- FUNÇÃO PRINCIPAL DE FÍSICA ---
# Roda a cada frame de física (fixo, ideal para movimento)
func _physics_process(_delta: float) -> void:
	# 1. OBTER O INPUT DO JOGADOR
	# get_vector mapeia as ações padrão (setas/WASD) para um vetor (-1 a 1)
	# ui_left, ui_right, ui_up, ui_down são pré-configuradas no Godot
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. CALCULAR A VELOCIDADE ALVO
	# Se houver input, a velocidade alvo é a direção * velocidade máxima.
	# normalized() já é garantido por get_vector, prevenindo movimento diagonal mais rápido.
	var target_velocity = input_direction * max_speed
	
	# 3. APLICAR ACELERAÇÃO E ATRITO SUAVE
	if input_direction != Vector2.ZERO:
		# Se estamos acelerando, use linear_interpolate (lerp) para suavizar
		velocity = velocity.lerp(target_velocity, acceleration_factor)
	else:
		# Se não há input, use lerp para desacelerar até zero (atrito)
		velocity = velocity.lerp(Vector2.ZERO, friction_factor)

	# 4. EXECUTAR O MOVIMENTO E A COLISÃO (A MÁGICA)
	# Esta função move o personagem com base em 'velocity'.
	# Se ele encontrar um CollisionPolygon2D (suas barreiras manuais),
	# ela impede que ele passe e faz ele "deslizar" ao longo da parede.
	move_and_slide()
	
	# 5. (OPCIONAL) ATUALIZAR ANIMAÇÕES OU DIREÇÃO DO SPRITE
	_update_sprite_direction()

# --- FUNÇÃO AUXILIAR PARA O SPRITE ---
# Exemplo simples de como virar o sprite com base na direção
func _update_sprite_direction() -> void:
	if input_direction.x > 0:
		# Indo para a direita, não inverte
		$Sprite2D.flip_h = false
	elif input_direction.x < 0:
		# Indo para a esquerda, inverte horizontalmente
		$Sprite2D.flip_h = true
	# Nota: Para animações completas (andar para cima/baixo), você usaria
	# um nó AnimationPlayer e um AnimationTree.
