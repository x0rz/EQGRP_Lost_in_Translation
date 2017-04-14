<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="peddlecheap_common.xsl"/>
	
	<xsl:param name="verbose" select="'false'"/>
  
	<xsl:template match="ConnectionReceived">
		<xsl:text>Connection received from [</xsl:text>
		<xsl:value-of select="Target/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Target/Port"/>
		<xsl:text> to [</xsl:text>
		<xsl:value-of select="Local/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Local/Port"/>
		<xsl:text>...</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>	

	<xsl:template match="PCProxy_Activity">
		<xsl:if test='$verbose = "true"'>
		<xsl:text>Activity on [</xsl:text>
		<xsl:value-of select="Local/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Local/Port"/>
		<xsl:text>...</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="PCProxy_ValidConnection">
		<xsl:if test='$verbose = "true"'>
		<xsl:text>Valid connection from on [</xsl:text>
		<xsl:value-of select="Target/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Target/Port"/>
		<xsl:text>...</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="PCProxy_ConnectionReceived">
		<xsl:if test='$verbose = "true"'>
		<xsl:text>Connection received from [</xsl:text>
		<xsl:value-of select="Target/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Target/Port"/>
		<xsl:text> to [</xsl:text>
		<xsl:value-of select="Local/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Local/Port"/>
		<xsl:text>...</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>PC Id: </xsl:text>
		<xsl:value-of select="Id"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Connection Index: </xsl:text>
		<xsl:value-of select="ConnectIndex"/>
		<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="PCProxy_HttpHeader">
		<xsl:if test='$verbose = "true"'>
		<xsl:text>Http Header -- length (</xsl:text>
		<xsl:value-of select="HeaderLength"/>
		<xsl:text>): </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="HttpHeader"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Bytes read from socket: </xsl:text>
		<xsl:value-of select="BytesRead"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Implant Id: </xsl:text>
		<xsl:value-of select="Id"/>
		<xsl:text>  Connection Index: </xsl:text>
		<xsl:value-of select="ConnectIndex"/>
		<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="PCProxyConnection_Activity">
		<xsl:if test='$verbose = "true"'>
		<xsl:text>Activity on Implant Socket [</xsl:text>
		<xsl:value-of select="Target/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Target/Port"/>
		<xsl:text>...</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>for Implant Id: </xsl:text>
		<xsl:value-of select="Id"/>
		<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="PCProxyConnection_ConnectionClosed">
		<xsl:if test='$verbose = "true"'>
		<xsl:text>Connection closed on Implant Socket [</xsl:text>
		<xsl:value-of select="Target/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Target/Port"/>
		<xsl:text>...</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>for Implant Id: </xsl:text>
		<xsl:value-of select="Id"/>
		<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="PCProxyConnection_TotalDataBytesToSend">
		<xsl:if test='$verbose = "true"'>
		<xsl:text>Received </xsl:text>
		<xsl:value-of select="DataBytesReceived"/>
		<xsl:text>bytes of data from Implant Id:</xsl:text>
		<xsl:value-of select="Id"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Content-Length: from the HTTP header is: </xsl:text>
		<xsl:value-of select="ContentLength"/>
		<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	

	<xsl:template match="PCProxyConnection_DataBytesSent">
		<xsl:if test='$verbose = "true"'>
		<xsl:value-of select="DataSent"/>
		<xsl:text>bytes of data have been sent to Implant Id:</xsl:text>
		<xsl:value-of select="Id"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="TotalBytes"/>
		<xsl:text>are the total bytes of data to be sent</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>

</xsl:transform>