extends Node
class_name Regular_value

var id
var tps
var value_init
var value = -1
var value_counter = -1
var tpf
var activated = false
var bursting = false
var decelerating = false
var just_finished=false
var has_deceleration
var dtps
var dtpf
var followup
var origin

func _init(nid,nvalue_init,ntps,nhas_deceleration=false,ndtps=0):
	id=nid
	value_init=nvalue_init
	tps=ntps
	has_deceleration=nhas_deceleration
	dtps=ndtps
	
	tpf = tps * 60
	dtpf = dtps * 60
	
	self.add_origin(self.pack_attributes(self))
		
func start():
	print("start ",id)
	reset_values()
	activated = true
	bursting=true
	decelerating=false
	just_finished=false
	value = value_init/tpf
	value_counter = 0

func end():
	print("end ",id)
	bursting=false
	if has_deceleration:
		start_deceleration()
	else:
		activated = false
		reset_values()
		switch_to_followup()

func return_value():
	if activated and bursting:
		value_counter+=value
		if abs(value_counter) >= abs(value_init):
			end()
			return 0
		return value
	elif activated and decelerating:
		if just_finished:
			just_finished = false
		value_counter=move_toward(value_counter,0,abs(value))
		if value_counter == 0:
			end_deceleration()
			return 0
		return value_counter
	else:
		return 0
	
func start_deceleration():
	if has_deceleration:
		reset_values()
		activated=true
		bursting=false
		decelerating = true
		value_counter =  value_init/ tpf
		value = value_init/ tpf / dtpf	

func end_deceleration():
	decelerating = false
	activated = false
	reset_values()
	
func reset_values():
	value=-1
	value_counter=-1
	tpf = tps * 60
	dtpf = dtps * 60

func has_just_finished():
	if just_finished:
		just_finished=false
		return true
	else:
		return just_finished 

func change_values(nvalue_init,ntps=null,ndtps=null):
	if not activated or just_finished:
		if nvalue_init != null:
			value_init=nvalue_init
		if ntps != null:
			tps = ntps
			tpf = tps * 60
		if ndtps != null:
			dtps = ndtps
			dtpf = dtps * 60

func add_followup(pack):
	if followup == null:
		followup=pack
		origin[5]=pack

func add_origin(pack):
	if origin == null:
		origin = pack

func switch_to_followup():
	if followup != null:
			unpack_attributes(followup)
			self.start()
	elif origin != self.pack_attributes() and origin != null:
		self.unpack_attributes(origin)
	else:
		print("No Maidens ??")

func pack_attributes(other=self):
	var final_pack=[other.id,other.value_init,other.tps,other.has_deceleration,other.dtps,other.followup]
	return final_pack

func unpack_attributes(pack):
	id=pack[0]
	value_init=pack[1]
	tps=pack[2]
	has_deceleration=pack[3]
	dtps=pack[4]
	followup=pack[5]
	activated=false
	decelerating=false
	just_finished=false
	reset_values()
