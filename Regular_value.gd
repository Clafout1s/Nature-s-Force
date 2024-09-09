extends Node
class_name Regular_value

var id
var value_init
var nb_frames
var deceleration_movement_value
var deceleration_frames
var deceleration_value
var value = -1
var value_counter = -1
var frame_counter = -1
var second_frame_counter
var step
var activated = false
var bursting = false
var decelerating = false
var just_finished=false
var has_deceleration
var followup
var origin
var deceleration_direction
var test = 0
#signal just_finished

func _init(nid,nvalue_init,nnb_frames,nhas_deceleration=false,ndeceleration_movement_value=null,ndeceleration_frames=1, ndeceleration_value=null):
	id=nid
	value_init=nvalue_init
	nb_frames=nnb_frames
	has_deceleration=nhas_deceleration
	if ndeceleration_movement_value == null:
		
		deceleration_movement_value = 0
	else:
		deceleration_movement_value = ndeceleration_movement_value
	deceleration_frames=ndeceleration_frames
	deceleration_direction = into_sign(deceleration_movement_value)
	if ndeceleration_value == null:
		deceleration_value = deceleration_movement_value / float(deceleration_frames) 
	else: 
		deceleration_value = ndeceleration_value
	#self.add_origin(self.pack_attributes(self))
		
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
		#switch_to_followup()
		just_finished = true
		#emit_signal("just_finished")

func return_value():
	if activated and bursting:
		value_counter+=value
		if abs(value_counter) >= abs(value_init):
			end()
			return 0
		return value
	elif activated and decelerating:
		var tempo = value_counter + value * second_frame_counter
		second_frame_counter -= step
		frame_counter+=1
		if frame_counter >= deceleration_frames:
			end_deceleration()
			return 0
		return tempo
	else:
		return 0
	
func start_deceleration():
	if has_deceleration:
		reset_values()
		activated=true
		bursting=false
		decelerating = true
		
		value_counter = deceleration_movement_value / deceleration_frames
		
		if deceleration_frames % 2 == 0:
			step = 2
			second_frame_counter = deceleration_frames-1
			value = value_counter / deceleration_frames
		else:
			step = 1
			second_frame_counter = deceleration_frames / int(2)
			value = value_counter / (deceleration_frames/int(2))
			
		frame_counter = 0

		
func end_deceleration():
	decelerating = false
	activated = false
	reset_values()
	#emit_signal("just_finished")
	just_finished = true
	
func reset_values():
	value=-1
	value_counter=-1
	frame_counter = -1
	just_finished = false

func global_end():
	if self.bursting:
		self.end()
	elif self.decelerating:
		self.end_deceleration()

func has_same_sign(f1:float,f2:float):
	return f1<0 and f2<0 or f1>0 and f2>0

func into_sign(f1:float):
	f1 = int(f1)
	if f1<0:
		return -1
	elif f1>0:
		return 1
	else:
		return 0

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
"""

