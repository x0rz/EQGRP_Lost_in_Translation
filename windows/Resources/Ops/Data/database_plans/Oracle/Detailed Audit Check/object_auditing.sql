select * from sys.dba_obj_audit_opts
where alt !='-/-' or aud !='-/-' or com !='-/-' or del !='-/-' or 
	gra !='-/-' or ind !='-/-' or ins !='-/-' or loc !='-/-' or 
	ren !='-/-' or sel !='-/-' or upd !='-/-' or ref !='-/-' or 
	exe !='-/-';
