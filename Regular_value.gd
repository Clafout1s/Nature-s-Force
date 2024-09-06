extends Node
class_name Regular_value

var id
var value_init
var nb_frames
var value_deceleration
var nb_frames_deceleration
var value = -1
var value_counter = -1
var activated = false
var bursting = false
var decelerating = false
#var just_finished=false
var has_deceleration
var followup
var origin
signal just_finished

func _init(nid,nvalue_init,nnb_frames,nhas_deceleration=false,nnb_frames_deceleration=0,nvalue_deceleration=nvalue_init):
	id=nid
	value_init=nvalue_init
	nb_frames=nnb_frames
	has_deceleration=nhas_deceleration
	value_deceleration = nvalue_deceleration
	nb_frames_deceleration=nnb_frames_deceleration
	
	self.add_origin(self.pack_attributes(self))
		
func start():
	reset_values()
	activated = true
	bursting=true
	decelerating=false
	value = value_init/nb_frames
	value_counter = 0

func end():
	bursting=false
	
	if has_deceleration:
		start_deceleration()
	else:
		activated = false
		reset_values()
		switch_to_followup()
		emit_signal("just_finished")

func return_value():
	if activated and bursting:
		value_counter+=value
		if abs(value_counter) >= abs(value_init):
			end()
			return 0
		return value
	elif activated and decelerating:
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
		value_counter =  value_deceleration / nb_frames
		value = value_deceleration / nb_frames/ nb_frames_deceleration

func end_deceleration():
	decelerating = false
	activated = false
	reset_values()
	emit_signal("just_finished")
	print("END OF SHOT")
	
func reset_values():
	value=-1
	value_counter=-1

"""
func change_values(nvalue_init,ntps=null,ndtps=null):
	if not activated or just_finished:
		if nvalue_init != null:
			value_init=nvalue_init
		if ntps != null:
			tps = ntps
		if ndtps != null:
			dtps = ndtps
			dtpf = dtps * 60
"""
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

func pack_attributes(other=self):
	var final_pack=[other.id,other.value_init,other.nb_frames,other.has_deceleration,other.nb_frames_deceleration,other.value_deceleration,other.followup]
	return final_pack

func unpack_attributes(pack):
	id=pack[0]
	value_init=pack[1]
	nb_frames=pack[2]
	has_deceleration=pack[3]
	nb_frames_deceleration=pack[4]
	value_deceleration = pack[5]
	followup=pack[6]
	
	activated=false
	decelerating=false
	reset_values()

func global_end():
	if self.bursting:
		self.end()
	elif self.decelerating:
		self.end_deceleration()
