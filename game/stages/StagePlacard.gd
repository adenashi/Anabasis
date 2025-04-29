class_name StagePlacard extends Control


#region Constants

const VISIBLE : float = 325.0
const HIDDEN : float = 1100.0

#endregion

#region Signals

signal ContinueToStage
signal RetryStage
signal GoToNextStage

#endregion

#region Exports

@export_group("Stage Start", "Start")
@export var StartPanel : PanelContainer
@export var StartHeading : Label
@export_subgroup("Enemy Labels", "Enemy")
@export var EnemyName : Label
@export var EnemyAttack : Label
@export var EnemyDefense : Label
@export var EnemyHealth : Label

@export_group("Stage Results", "Results")
@export var ResultsPanel : PanelContainer
@export var ResultsHeading : Label
@export var ResultsStageName : Label
@export var ResultsEnemyName : Label
@export var ResultsTimeLabel : Label
@export var ResultsReshufflesLabel : Label
@export var ResultsScoreLabel : Label

@export_group("Buttons", "Stage")
@export var StageStartButton : Button
@export var StageRetryButton : Button
@export var StageNextButton : Button
@export var StageMainMenuButton : Button

#endregion

#region Private Variables

var posTween : Tween
var currentEnemy : EnemyData
var currentResults : Dictionary
var panel : PanelContainer
var showInfo : Callable

var enemyName : String
var fake_enemy_name : String : set = set_fake_enemy_name
var enemyAttack : int
var fake_enemy_attack : int : set = set_fake_enemy_attack
var enemyArmor : int
var fake_enemy_armor : int : set = set_fake_enemy_armor
var enemyHealth : int
var fake_enemy_health : int : set = set_fake_enemy_health

var GameTime : int
var fake_time : int : set = set_fake_time
var Reshuffles : int
var fake_reshuffles : int : set = set_fake_reshuffles
var Score : int
var fake_score : int : set = set_fake_score

#endregion

#region Input Event Functions

func on_continue_button_pressed() -> void:
	ContinueToStage.emit()


func on_retry_stage_button_pressed() -> void:
	RetryStage.emit()


func on_next_stage_button_pressed() -> void:
	GoToNextStage.emit()


func on_main_menu_button_pressed() -> void:
	GUI.show_main_menu_confirmation()

#endregion

#region Gameplay Functions

func on_next_enemy(enemy : EnemyData) -> void:
	currentEnemy = enemy
	prepare_start_placard()
	panel = StartPanel
	showInfo = show_stage_start
	raise()


func prepare_start_placard() -> void:
	ResultsPanel.hide()
	StartPanel.show()
	EnemyName.text = ""
	EnemyAttack.text = "0"
	EnemyDefense.text = "0"
	EnemyHealth.text = "0"
	StartHeading.text = currentEnemy.Stage
	StageMainMenuButton.hide()
	StageStartButton.hide()
	StageStartButton.disabled = true


func show_stage_start() -> void:
	await get_tree().create_timer(1.0).timeout
	await set_enemy_name(currentEnemy.Name)
	await set_enemy_attack(currentEnemy.Attacks[2])
	await set_enemy_armor(currentEnemy.MaxDefense)
	await set_enemy_health(currentEnemy.MaxHealth)
	StageStartButton.show()
	StageStartButton.disabled = false
	StageMainMenuButton.show()


func on_stage_cleared(results : Dictionary) -> void:
	currentResults = results
	prepare_results_placard()
	panel = ResultsPanel
	showInfo = show_stage_results
	raise()


func prepare_results_placard() -> void:
	StartPanel.hide()
	ResultsPanel.show()
	ResultsHeading.text = currentResults.Result
	ResultsStageName.text = currentEnemy.Stage
	ResultsEnemyName.text = "Home of " + currentEnemy.Name
	ResultsTimeLabel.text = "00:00:00"
	ResultsReshufflesLabel.text = "0"
	ResultsScoreLabel.text = "0"
	StageMainMenuButton.hide()
	StageRetryButton.hide()
	StageRetryButton.disabled = true
	StageNextButton.hide()
	StageNextButton.disabled = true


func show_stage_results() -> void:
	await get_tree().create_timer(0.8).timeout
	await set_time(currentResults.Time)
	await set_reshuffles(currentResults.Reshuffles)
	await set_score(currentResults.Score)
	match currentResults.Result:
		"Victory":
			StageNextButton.show()
			StageNextButton.disabled = false
		"Defeat":
			StageRetryButton.show()
			StageRetryButton.disabled = false
	StageMainMenuButton.show()


func reset_placard() -> void:
	hide()
	ResultsPanel.hide()
	StartPanel.hide()

#endregion

#region Aesthetics

func raise() -> void:
	show()
	reset_pos_tween()
	posTween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	posTween.tween_property(panel, "position:y", VISIBLE, 2.0)
	posTween.tween_callback(showInfo)
	
	await posTween.finished
	posTween = null


func lower() -> void:
	reset_pos_tween()
	posTween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	posTween.tween_property(panel, "position:y", HIDDEN, 2.0)
	
	await posTween.finished
	posTween = null
	reset_placard()


func reset_pos_tween() -> void:
	if posTween:
		posTween.kill()
	
	posTween = create_tween()

#endregion

#region Label Tweens

func set_enemy_name(value : String) -> void:
	enemyName = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_enemy_name", enemyName, 1.0)
	await tween.finished


func set_fake_enemy_name(value : String) -> void:
	fake_enemy_name = value
	EnemyName.text = fake_enemy_name


func set_enemy_attack(value : int) -> void:
	enemyAttack = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_enemy_attack", enemyAttack, 1.0)
	await tween.finished


func set_fake_enemy_attack(value : int) -> void:
	fake_enemy_attack = value
	EnemyAttack.text = str(fake_enemy_attack)


func set_enemy_armor(value : int) -> void:
	enemyArmor = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_enemy_armor", enemyArmor, 1.0)
	await tween.finished


func set_fake_enemy_armor(value : int) -> void:
	fake_enemy_armor = value
	EnemyDefense.text = str(fake_enemy_armor)


func set_enemy_health(value : int) -> void:
	enemyHealth = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_enemy_health", enemyHealth, 1.0)
	await tween.finished


func set_fake_enemy_health(value : int) -> void:
	fake_enemy_health = value
	EnemyHealth.text = str(fake_enemy_health)


func set_time(value : int) -> void:
	GameTime = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_time", GameTime, 1.0)
	await tween.finished


func set_fake_time(value : int) -> void:
	fake_time = value
	ResultsTimeLabel.text = Util.formatted_game_time(fake_time)


func set_reshuffles(value : int) -> void:
	Reshuffles = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_reshuffles", Reshuffles, 1.0)
	await tween.finished


func set_fake_reshuffles(value : int) -> void:
	fake_reshuffles = value
	ResultsReshufflesLabel.text = str(fake_reshuffles)


func set_score(value : int) -> void:
	Score = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_score", Score, 1.0)
	await tween.finished


func set_fake_score(value : int) -> void:
	fake_score = value
	ResultsScoreLabel.text = str(fake_score)

#endregion

#region Debugging TODO: Delete Later!



#endregion
