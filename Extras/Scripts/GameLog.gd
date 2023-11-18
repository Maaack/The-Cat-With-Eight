class_name GameLog
extends Node

const GAME_LOG_SECTION = "GameLog"
const TOTAL_GAMES_STARTED = "TotalGamesStarted"
const OPENING_SEEN = "OpeningSeen"

static func game_started() -> void:
	var total_games_started = Config.get_config(GAME_LOG_SECTION, TOTAL_GAMES_STARTED, 0)
	total_games_started += 1
	Config.set_config(GAME_LOG_SECTION, TOTAL_GAMES_STARTED, total_games_started)

static func opening_seen() -> void:
	Config.set_config(GAME_LOG_SECTION, OPENING_SEEN, true)

static func has_seen_opening() -> bool:
	return Config.get_config(GAME_LOG_SECTION, OPENING_SEEN, false)
