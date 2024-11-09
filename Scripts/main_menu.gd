extends CanvasLayer

func _on_address_edit_text_changed(new_text: String) -> void:
	owner.address = new_text


func _on_host_pressed() -> void:
	owner.host()


func _on_join_pressed() -> void:
	owner.join()
