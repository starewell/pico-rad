--global ●
--grid vars
grid={size=06,
	sqrs={},
	sqr_size=16,						
	sqr_offset={x=8,y=5},
	edge_offset={y=12}
}
					
--player vars
blue={
	state="slct_card",
	co={},
	slctd_tkn=nil,
	tkns={},
	move={valid={}},
	slctd_card={},
	hand={},
	hand_offset=110,
	deck={},
	discard={}
}

red={
	state="slct_card",
	co={},
	slctd_tkn=nil,
	tkns={}, 
	move={valid={}},
	slctd_card,
	hand={},
	deck={},
	discard={}
}

tkn_yoffset=2

--crsr vars, sprite display and animation
crsr={
	slct={hvr={},
		sp=04,
		t=0,
		i=2},
	show={hvr={},
		sp=14,
		t=0,
		i=2},
	card={hvr={coord={x=0}},
		sp=48,
		t=0,
		i=1},
	anim={spd=.2}
}

--turn vars
turn={state="plyr", actions=0}
						
--card atlas, sprite display and valid movement paths
--will need restructuring if blocking is used
move_atls={
	cntr_offset={x=12,y=8},
	moves={{i=1,
		_spr={s=128,w=2,h=1},
		paths={
			{{x=-1,y=-1},
			{x=-2,y=-2}},
			{{x=1,y=-1},
			{x=2,y=-2}}}},
		{i=2,
		_spr={s=130,w=1,h=1},
		paths={
			{{x=0,y=-1},
			{x=0,y=-2},
			{x=1,y=-2}},
			{{x=0,y=-1},
			{x=0,y=-2},
			{x=-1,y=-2}}}},
	 	{i=3,
		_spr={s=131,w=1,h=1},
		paths={
			{{x=0,y=1},
			{x=0,y=2},
			{x=-1,y=2}},
			{{x=0,y=1},
			{x=0,y=2},
			{x=1,y=2}}}},
		{i=4,
		_spr={s=132,w=1,h=1},
		paths={
			{{x=-1,y=0},
 			{x=-2,y=0},
			{x=-2,y=-1}},
			{{x=-1,y=0},
			{x=-2,y=0},
			{x=-2,y=1}}}},
		{i=5,
		_spr={s=133,w=1,h=1},
		paths={
			{{x=1,y=0},
			{x=2,y=0},
			{x=2,y=-1}},
			{{x=1,y=0},
			{x=2,y=0},
			{x=2,y=1}}}},
		{i=6,
		_spr={s=134,w=1,h=1},
		paths={
			{{x=-1,y=0},
			{x=-2,y=0}},
			{{x=0,y=1},
			{x=0,y=2}}}},	
		{i=7,
		_spr={s=135,w=1,h=1},
		paths={
			{{x=1,y=0},
			{x=2,y=0}},
			{{x=0,y=1},
			{x=0,y=2}}}},	
		{i=8,
		_spr={s=136,w=1,h=1},
		paths={
			{{x=-1,y=0},
			{x=-2,y=0}},
			{{x=0,y=-1},
			{x=0,y=-2}}}},
		{i=9,
		_spr={s=137,w=1,h=1},
		paths={
			{{x=1,y=0},
			{x=2,y=0}},
			{{x=0,y=-1},
			{x=0,y=-2}}}},
		{i=10,
		_spr={s=138,w=1,h=1},
		paths={
			{{x=-1,y=-1},
			{x=-2,y=-2}}}},
		{i=11,
		_spr={s=139,w=1,h=1},
		paths={
			{{x=1,y=-1},
			{x=2,y=-2}}}},
		{i=12,
		_spr={s=140,w=1,h=1},
		paths={
			{{x=-1,y=1},
			{x=-2,y=2}}}},
		{i=13,
		_spr={s=141,w=1,h=1},
		paths={
			{{x=1,y=1},
			{x=2,y=2}}}}
	}
}

--util functions

--get grid index from coords
function sqr_i(sqr)
	return sqr.x*(grid.size)+sqr.y+1
end

--check if table is empty
function is_empty(t)
	for _,_ in pairs(t) do
		return false
	end
	return true
end

--lerp 2 vector 2
debug=nil
function v2lerp(from,to,p)
	debug={x=from.x+p/100*(to.x - from.x), y=from.y+p/100*(to.y - from.y)}
	return debug
end

--compare 2 vector 2
function pos_compare(pos1,pos2)
	if (pos1.x==pos2.x and pos1.y==pos2.y) then return true end
	return false
end




--initialization ⌂
function _init()
	init_grid()
	init_deck(blue)
	init_deck(red)
	crsr.card.hvr={coord={x=1}}
	blue.slctd_card=blue.hand[1]	
	t={x=grid.size-1,y=grid.size-1}
	crsr.slct.hvr=grid.sqrs[sqr_i(t)]
end

function init_grid()
	for _x=0, grid.size-1 do
		for _y=0, grid.size-1 do
--add squares to grid
			t={x=_x,y=_y}
			index=sqr_i(t)
			origin={x=56,
				y=57-grid.size*grid.sqr_offset.y}
			if (_x%2==0) then
				if (_y%2==0) then _white=true else _white=false end
			else
				if (_y%2==0) then	_white=false else _white=true end
			end
--sqr definition
			add(grid.sqrs,
				{coord={
					x=_x,
					y=_y},
				pos={
					x=origin.x+_x*grid.sqr_offset.x-_y*grid.sqr_offset.x,
					y=origin.y+_y*grid.sqr_offset.y+_x*grid.sqr_offset.y},
				white=_white
			})

--add 4 tokens to grid if current sqr is centered and on opposite sides of the board
			if (_y==0 and _x>(grid.size-4)/2-1 and _x<grid.size-(grid.size-4)/2) then
--tkn definition
				add(red.tkns,
					{coord={x=_x,y=_y},
					pos={x=grid.sqrs[index].pos.x,
					y=grid.sqrs[index].pos.y-tkn_yoffset},
					locked=false,
					i=#red.tkns+1
				})
			end
--add 4 tokens to grid if current sqr is centered and on opposite sides of the board
			if (_y==grid.size-1 and _x>(grid.size-4)/2-1 and _x<grid.size-(grid.size-4)/2) then
--tkn definition
				add(blue.tkns,
					{coord={x=_x,y=_y},
					pos={x=grid.sqrs[index].pos.x,
					y=grid.sqrs[index].pos.y-tkn_yoffset},
					locked=false,
					i=#blue.tkns+1
				})
			end
		end
	end
end

--create a deck of one of each card in the atlas (excluding the start move card)
--deal 5 cards into the players hand
function init_deck(_plyr)
	for i=2,#move_atls.moves do
		c={move=move_atls.moves[i],
			slctd=false, 
			pos={x=0,y=0}}
		add(_plyr.deck,c)
	end
	for i=1,4 do
		add_card(_plyr)
	end			
end

function shuffle_deck(_plyr)
	for card in all(_plyr.discard) do
		add(_plyr.deck,card)
		del(_plyr.discard,card)
	end
end


--this one is a dealing function >.>
function draw_to_four(_plyr)
	while(#_plyr.hand<4) do
		if(#_plyr.deck>0) then add_card(_plyr)
		elseif(#_plyr.deck<=0) then 
			shuffle_deck(_plyr) 
			add_card(_plyr)
		end
	end
end

--remove random card from deck, add to hand
function add_card(_plyr)
	crd=rnd(_plyr.deck)
	del(_plyr.deck,crd)
	add(_plyr.hand,crd)
	if (_plyr==blue) then
		update_hand(_plyr)
	end
end

--recalculate screenspace position of cards
--needs to be centered when fewer than 5
function update_hand(_plyr)
	i=0
	for crd in all(_plyr.hand) do
		crd.pos={x=59-(#_plyr.hand*21/2)+i*21,y=101}
		i+=1
		_plyr.hand[i].slctd=false
		if (i==crsr.card.hvr.coord.x and _plyr.state~="end_io" and turn.state~="opnt") then
			_plyr.hand[i].slctd=true
		end
	end
end
--  ___   __   _  _  ____    ____  _  _  __ _ 
-- / __) / _\ ( \/ )(  __)  (  _ \/ )( \(  ( \
--( (_ \/    \/ \/ \ ) _)    )   /) \/ (/    /
-- \___/\_/\_/\_)(_/(____)  (__\_)\____/\_)__)																			
--game run 웃

--a mess of a state machine! pretty straightforward tho
function _update()
	if(turn.state=="plyr") then 
		if (blue.state=="end_io") then
			end_turn()
		elseif(blue.state=="slct_card") then
			slct_card()
		elseif(blue.state=="slct_ally") then
			grid_move()
			slct_ally()
		elseif (blue.state=="move_ally") then
			grid_move()
			move_ally()
		elseif (blue.state=="co") then
--run whatever coroutines were created in blue until they die
			co_loop(blue)
		end
	elseif(turn.state=="opnt") then
		blue.slctd_card={}
		if (red.state=="slct_card") then
			opnt_turn()
		elseif (red.state=="co") then
			co_loop(red)
		end
	end
end

function co_loop(_plyr) 
	if(_plyr.co[1] and costatus(_plyr.co[1])~='dead') then
		coresume(_plyr.co[1])
	else
		_plyr.co[1]=nil
		del(_plyr.co,_plyr.co[1])
		if (is_empty(_plyr.co)) then 
			turn_action(_plyr)
		end
	end
end

--initializes state-specific variables before switching states
--util function really, optimizes code but needs optimizing itself
function switch_state(_plyr,state)
	if (_plyr==blue) then
		if (state=="slct_card") then
			if (_plyr.state=="co") then 
				_plyr.slctd_tkn.locked=true
				add(_plyr.discard,_plyr.slctd_card)
				del(_plyr.hand,_plyr.slctd_card)
				_plyr.slctd_card={}
				crsr.card.hvr.coord.x=1 
				_plyr.slctd_tkn={}
			end		
			_plyr.move.valid={}
		elseif (state=="slct_ally") then
			if (not is_empty(_plyr.slctd_tkn)) then
				crsr.slct.sqr=crsr.show.sqr
			end
			_plyr.slctd_tkn={}		
			_plyr.move.valid={}
			crsr.slct.sp=04
			crsr.slct.i=2
		elseif (state=="move_ally") then
			crsr.show.hvr=crsr.slct.hvr
			crsr.show.sp=04
			crsr.show.i=2
			crsr.slct.sp=36
			crsr.slct.i=2
		elseif (state=="co") then	
			_plyr.move.valid={}
		elseif (state=="end_io") then
			_plyr.slctd_card={}
		end
	elseif (_plyr==red) then
		if (state=="slct_card") then
			if (_plyr.state=="co") then
				_plyr.slctd_tkn.locked=true
			end
			_plyr.slctd_tkn={}
		end
	end
	_plyr.state=state
end

function switch_turns() 
	turn.actions=0
	if (turn.state=="plyr") then
		reset_turn(blue)
		draw_to_four(red)
		turn.state="opnt"
		switch_state(red,"slct_card")
	elseif (turn.state=="opnt") then
		reset_turn(red)
		draw_to_four(blue)
		turn.state="plyr"
		switch_state(blue,"slct_card")
	end

	update_hand(blue)
end

function reset_turn(_plyr)
	for tkn in all(_plyr.tkns) do tkn.locked=false end
	for card in all(_plyr.hand) do
		add(_plyr.discard,card)
		del(_plyr.hand,card)
	end
end

function turn_action(_plyr)
	turn.actions+=1
	switch_state(_plyr, "slct_card")
	if (turn.actions==2) then
		switch_turns()
	end
end

function opnt_turn()
	bool=opnt_capture_scan()
	if (not bool) then opnt_play_card() end
end

function opnt_capture_scan()
	red.slctd_tkn=nil
	red.slctd_card=nil
	red.move.valid={}
	for tkn in all(red.tkns) do
		if (not tkn.locked) then
			red.slctd_tkn=tkn
			for card in all (red.hand) do
				red.move.valid={}
				red.slctd_card=card
				set_valid_move(red, blue)
				for v in all(red.move.valid) do
					for plyr_tkn in all(blue.tkns) do
						if (pos_compare(v,plyr_tkn.coord)) do
							crsr.slct.hvr=grid.sqrs[sqr_i(v)]
							params=reverse_search_path(red)
							val1=tostr(params.path[params.index].x)..","..tostr(params.path[params.index].y)
							val2=tostr(v.x)..","..tostr(v.y)
							init_path_co(red,blue,params.path,params.index)

							add(red.discard,red.slctd_card)
							del(red.hand,red.slctd_card)
							red.move.valid={}
							red.slctd_card=nil
							return true
						end
					end
				end
				red.move.valid={}
			end
		end
	end
	red.slctd_tkn={}
	return false
end

function opnt_play_card()
	red.scltd_tkn={}
	red.slctd_card=nil
	stkns={}
	for i,v in ipairs(red.tkns) do
		if (not v.locked) then add(stkns,v) end
	end
	red.slctd_tkn=rnd(stkns)

	shand={}
	for i,v in ipairs(red.hand) do
		red.move.valid={}
		red.slctd_card=v
		set_valid_move(red,blue)
		if (not is_empty(red.move.valid)) then add(shand,v) end
	end
	if (is_empty(shand)) then 
		turn_action(red)
		return 
	end
	red.move.valid={}
	red.slctd_card=rnd(shand)
	set_valid_move(red,blue)

	if (is_empty(red.move.valid)) then
		turn_action(red)
	end
	coord=rnd(red.move.valid)
	crsr.slct.hvr=grid.sqrs[sqr_i(coord)]

	params=reverse_search_path(red)
	val2=#params.path

	init_path_co(red,blue,params.path,params.index)

	add(red.discard,red.slctd_card)
	del(red.hand,red.slctd_card)
	red.move.valid={}
	red.slctd_card=nil
end

--check if crsr is on a blue.tkn
function slct_ally()
--cancel slct
	if (btnp(5)) then
		switch_state(blue,"slct_card")
	end
--trigger slct
	if (btnp(4)) then
		for tkn in all(blue.tkns) do
			if(pos_compare(crsr.slct.hvr.coord,tkn.coord) and not tkn.locked) then
--grid crsr is over an ally tkn			
				blue.slctd_tkn=tkn
				set_valid_move(blue, red)
				switch_state(blue,"move_ally")
			end
		end
	end
end

--check if crsr is on a valid move
function move_ally()
--cancel move
	if(btnp(5)) then	
		switch_state(blue,"slct_ally")
	end
--trigger move
	if (btnp(4)) then
		valid=false
		for coord in all(blue.move.valid) do
			if(pos_compare(crsr.slct.hvr.coord,coord)) then			
--grid crsr is over a valid move
				params=reverse_search_path(blue)
--loop through each step in the path before slctd sqr and create lerp coroutine to execute in order
				init_path_co(blue,red,params.path,params.index)
			end
		end
		if (valid and #blue.hand<=0) then turn.state="game_over"
		elseif (not valid) then
--			switch_state(blue,"slct_ally")
		end		
	end
end

function reverse_search_path(_plyr) 
	valid=true
	i=0 
	p={}
	for path in all(_plyr.slctd_card.move.paths) do
		if (not is_empty(p)) then break end
		i=0
		for c in all(path) do
			i+=1
			t={x=_plyr.slctd_tkn.coord.x+c.x,y=_plyr.slctd_tkn.coord.y+c.y}
			if (pos_compare(crsr.slct.hvr.coord,t)) then 
				p=path
				break 
			end
		end
	end
	return {path=p, index=i}
end


function init_path_co(_plyr, _opnt, p, i)
	for n=1,i do
		--start coroutine, initialize function parameters in first coresume, continually called in state machine
		_plyr.co[n]=cocreate(slide_movement)
		tar={x=_plyr.tkns[_plyr.slctd_tkn.i].coord.x+p[n].x,y=_plyr.tkns[_plyr.slctd_tkn.i].coord.y+p[n].y}
		coresume(_plyr.co[n],_plyr,_opnt,_plyr.tkns[_plyr.slctd_tkn.i],tar)
	end
	switch_state(_plyr,"co")
end

--couroutine! a simple lerp, plan to structure it into a macro coroutine to loop through path coords
function slide_movement(_plyr,_opnt,tkn, to)
	yield()

	origin={x=tkn.pos.x,y=tkn.pos.y}
	dest={x=grid.sqrs[sqr_i(to)].pos.x,y=grid.sqrs[sqr_i(to)].pos.y-tkn_yoffset}

--lerp works by percantage, loop through 100
	for p=1,100,10 do
--set tkn pos to lerpd pos
		tkn.pos=v2lerp(origin,dest,p)
		yield() --coroutine!
	end
--hard set slctd_tkn's pos and grid coordinate after lerp
	tkn.pos={
		x=dest.x,
		y=dest.y}		
	tkn.coord={
		x=to.x,
		y=to.y}
	for o in all(_opnt.tkns) do
		if (pos_compare(o.coord,tkn.coord)) then
			del(_opnt.tkns,o)
		end
	end
end

--translate coords from card instance into relevant coords for tkn
--remove coords that are occupied or off the board
function set_valid_move(_plyr, _opnt)
	t=_plyr.slctd_tkn.coord
--loop through each path
	for path in all(_plyr.slctd_card.move.paths) do
		blocked=false
--loop through each coordinate
		for c in all(path) do
			d={x=t.x+c.x,y=t.y+c.y}
			if (d.x<0 or d.x>grid.size-1 or d.y<0 or d.y>grid.size-1) then
--coordinate off grid
				blocked=true
			end
			for tkn in all(_plyr.tkns) do
				if(pos_compare(d,tkn.coord)) then
--coordinate occupied by blue tkn
					blocked=true
				end
			end
--if blocked, break out of this path, but search others
			if (blocked) then break end
--otherwise add this coord to valid
			add(_plyr.move.valid,d)
			for tkn in all(_opnt.tkns) do
				if (pos_compare(d,tkn.coord)) then
					blocked = true
					break
				end
			end
		end
	end
end

--move card crsr by button input
function slct_card()
	if(btnp(0) and crsr.card.hvr.coord.x>1) then
		crsr.card.hvr.coord.x-=1
		blue.slctd_card=blue.hand[crsr.card.hvr.coord.x]			
	end
	if (btnp(1) and crsr.card.hvr.coord.x<#blue.hand) then
		crsr.card.hvr.coord.x+=1
		blue.slctd_card=blue.hand[crsr.card.hvr.coord.x]			
	elseif(btnp(1) and crsr.card.hvr.coord.x==#blue.hand) then
		switch_state(blue,"end_io")
	end
	if(btnp(4)) then
		blue.slctd_card=blue.hand[crsr.card.hvr.coord.x]
		switch_state(blue,"slct_ally")
	end
	update_hand(blue)
	if (blue.state~="end_io" and turn.state~="opnt") then
		blue.hand[crsr.card.hvr.coord.x].pos.y-=5
	end	
end

function end_turn()
	if(btnp(4)) then
		switch_state(blue,"slct_card")
		switch_turns()
	end
	if(btnp(5) or btnp(0) or btnp(1)) then
		switch_state(blue,"slct_card")
	end
end

--move grid slct crsr by button input
function grid_move()
	if(btnp(0) and crsr.slct.hvr.coord.x>0) then
		t={x=crsr.slct.hvr.coord.x-1,y=crsr.slct.hvr.coord.y}
		crsr.slct.hvr=grid.sqrs[sqr_i(t)]
	end
	if(btnp(1) and crsr.slct.hvr.coord.x<grid.size-1) then
		t={x=crsr.slct.hvr.coord.x+1,y=crsr.slct.hvr.coord.y}
		crsr.slct.hvr=grid.sqrs[sqr_i(t)]
	end
	if(btnp(2) and crsr.slct.hvr.coord.y>0) then
		t={x=crsr.slct.hvr.coord.x,y=crsr.slct.hvr.coord.y-1}
		crsr.slct.hvr=grid.sqrs[sqr_i(t)]
	end
	if(btnp(3) and crsr.slct.hvr.coord.y<grid.size-1) then
		t={x=crsr.slct.hvr.coord.x,y=crsr.slct.hvr.coord.y+1}
		crsr.slct.hvr=grid.sqrs[sqr_i(t)]
	end
end



--game draw ▒

--just a tangle of functions
function _draw()
	cls(0)
	draw_grid()
	draw_valid()
--if there is a crsr on the board
	if(not is_empty(crsr.slct.hvr)) then
		draw_crsr() 
	end
--display original slctd crsr when slcting where to move a tkn
	if(not is_empty(blue.slctd_tkn) and blue.state ~= "co") then
		crsr_scroll(crsr.show,04,06)
	end
	draw_tkns()

	draw_actions()
	draw_end_button()
	
	draw_deck()
	draw_hand()

--	debug_turns()
end

function draw_grid()
--set sprites to sqr color
	for sqr in all(grid.sqrs) do
		if (sqr.white) then 
			sqrsp=0
			edgesp=32
		else
			sqrsp=2
			edgesp=33
		end
		
--draw sqr
		spr(sqrsp,sqr.pos.x,sqr.pos.y,2,2)
--draw edge
		if (sqr.coord.y==grid.size-1) then
			spr(edgesp,sqr.pos.x,sqr.pos.y+grid.edge_offset.y,1,1)
		end
		if (sqr.coord.x==grid.size-1) then
			spr(edgesp,sqr.pos.x+grid.sqr_size/2,sqr.pos.y+grid.edge_offset.y-1,1,1,false,true)
		end
	end
end

function draw_valid()
--draw valid movement
	for coord in all(blue.move.valid) do
		for sqr in all(grid.sqrs) do
			if(pos_compare(coord,sqr.coord)) then
--draw valid vis
				spr(34,sqr.pos.x,sqr.pos.y,2,2)
			end
		end
	end	
end

--set sprites to color crsr based on state
function draw_crsr()
	if (blue.state=="slct_ally") then
		crsr_scroll(crsr.slct,04,06)
	elseif (blue.state=="move_ally") then
		crsr_scroll(crsr.slct,36,38)
	end
	
end

--function used by grid csrs and hand crsr. ping-pong between l and h
function crsr_scroll(_crsr,l,h)
	spr(_crsr.sp,_crsr.hvr.pos.x,_crsr.hvr.pos.y,abs(_crsr.i),abs(_crsr.i))
	if (time()-_crsr.t>crsr.anim.spd) then
		_crsr.t=time()
		_crsr.sp+=_crsr.i
		if(_crsr.sp==l or _crsr.sp==h) then
			_crsr.i=-_crsr.i
		end
	end
end

function draw_tkns()
--draw blue tokens
	for tkn in all(blue.tkns) do
		if (tkn.locked) then i=66 else i=64 end
		spr(i, tkn.pos.x,tkn.pos.y,2,2)
	end
--draw red tokens
	for tkn in all(red.tkns) do
		if (tkn.locked) then i=98 else i=96 end
		spr(i, tkn.pos.x,tkn.pos.y,2,2)
	end
end

function draw_actions()
	sp=08
	c=7
	if (turn.state=="plyr") then
		acts=tostr(2-turn.actions).."/2"
	else
		acts="0/2"
		sp=10
		c=06
	end
	spr(sp, 2,98,2,2)
	print(acts,5,104,0)
	print(acts,4,103,c)
end

--render, not deal new card
function draw_card(crd,slctd)
	spr(76,crd.pos.x,crd.pos.y,4,4)
	spr(crd.move._spr.s,crd.pos.x+move_atls.cntr_offset.x,crd.pos.y+move_atls.cntr_offset.y,crd.move._spr.w,crd.move._spr.h)
	if(slctd) then
		spr(72,crd.pos.x,crd.pos.y,4,4)
	elseif(blue.state~="slct_card") then
		spr(68,crd.pos.x,crd.pos.y,4,4)
	end	
end


function draw_hand()
	for i=1,#blue.hand do
		draw_card(blue.hand[i],blue.hand[i].slctd)
	end
	if(turn.state=="plyr" and blue.state=="slct_card") then
		crsr.card.hvr.pos={x=50-(#blue.hand*21/2)+crsr.card.hvr.coord.x*21,y=91}
		crsr_scroll(crsr.card,48,49)
	end
end

function draw_deck()
	spr(14,2,114,2,2)
	print(#blue.deck,9,119,0)
	print(#blue.deck,8,118,7)

end

function draw_end_button()
	if (blue.state=="end_io") then sp=42 else sp=40	end
	spr(sp,108,108,2,2)
end

function debug_turns()
	str=red.state.."\n"..tostr(bool1).."\n"..tostr(val1).."\n"..tostr(val2)
	print(str,4,4,7)
end