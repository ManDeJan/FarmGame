extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func update_corn(corn_count):
    $Maisteller.text = str(corn_count)

func update_month(month):
    $Month.text = str(month)

func update_zaad(zaad_count):
    $Zaadteller.text = str(zaad_count)

func update_cashmoney(cash_money):
    $Cashmoney.text = str(cash_money)

func update_stonk(stonk):
    $Stonk.text = str(stonk)
