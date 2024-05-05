extends Node
class_name Regular_value

var id
var tps
var value_init
var value = -1
var value_counter = -1
var tpf
var activated = false
var decelerating = false
var has_deceleration
var dtps
var dtpf

func _init(nid,nvalue_init,ntps,nhas_deceleration=false,ndtps=0):
	id=nid
	value_init=nvalue_init
	tps=ntps
	has_deceleration=nhas_deceleration
	dtps=ndtps
	
	tpf = tps * 60
	if has_deceleration:
		dtpf = dtps * 60

func start():
	activated = true
	value = value_init/tpf
	value_counter = 0

func end():
	if has_deceleration:
		start_deceleration()
	else:
		activated = false
		reset_values()

func return_value():
	if activated and not decelerating:
		value_counter+=value
		if value_counter == value_init:
			end()
		return value
	elif activated and decelerating:
		value_counter=move_toward(value_counter,0,value)
		if value_counter == 0:
			end_deceleration()
		return value_counter
	
func start_deceleration():
	decelerating = true
	value = value_init/ tpf / dtpf
	value_counter = value

func end_deceleration():
	decelerating = false
	activated = false
	reset_values()
	
func reset_values():
	value=-1
	value_counter=-1
	
"""
tps : init
	value_init : init
	value=-1
	value_counter=-1
	tpf = tps*60
	activated=false
	decelerating=false
	has_deceleration : init
	dtps: init
	dtpf=tps*60
	
	func start():
		activated = true
		value=value_init/tpf
		value_counter=0
	func end():
		
		if has_deceleration:
			deceleration_start()
		else:
			activated = false
			reset_values()
	func return_value():
		if activated and not decelerating:
			value_counter+=value
			if value_counter==value_init:
				end()
			return value
		elif activated and decelerating:
			value_counter = move_toward(value_counter,0,value)
			if value_counter==0:
				end_deceleration()
			return value_counter
			
	func start_deceleration():
		#activated stays true
		decelerating = true
		value=(value_init/tpf)/dtpf
		value_counter = value
	
	func end_deceleration():
		deceleration = false
		reset_values()
		
	func reset_values():
		value=-1
		value_counter=-1



"""

