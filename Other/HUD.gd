extends CanvasLayer

@onready var CurrentAmmoLabel = $VBoxContainer/HBoxContainer/CurrentAmmo
@onready var CurrentWeaponLabel = $VBoxContainer/HBoxContainer2/CurrentWeapon

func _on_weapons_manager_update_ammo(Ammo):
	CurrentAmmoLabel.set_text(str(Ammo[0])+" / "+ str(Ammo[1]))

func _on_weapons_manager_weapon_changed(Weapon_Name):
	pass
