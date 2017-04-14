<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="Listening">
		<xsl:text>Listening on node </xsl:text>
		<xsl:value-of select="@commsAddress"/>
		<xsl:text> at address </xsl:text>
		<xsl:value-of select="Local/@ip"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="Local/@port"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="NewConnection">
		<xsl:text>New connection received on node </xsl:text>
		<xsl:value-of select="@commsAddress"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Listen Address - </xsl:text>
		<xsl:value-of select="Local/@ip"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="Local/@port"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Connecting Address - </xsl:text>
		<xsl:value-of select="Remote/@ip"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="Remote/@port"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="RejectedConnection">
		<xsl:text>Connection rejected on node </xsl:text>
		<xsl:value-of select="@commsAddress"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Local Address - </xsl:text>
		<xsl:value-of select="Local/@ip"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="Local/@port"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Remote Address - </xsl:text>
		<xsl:value-of select="Remote/@ip"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="Remote/@port"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="ClosedConnection">
		<xsl:text>Closed connection on node </xsl:text>
		<xsl:value-of select="@commsAddress"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Node Local Address - </xsl:text>
		<xsl:value-of select="Local/@ip"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="Local/@port"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Node Remote Address - </xsl:text>
		<xsl:value-of select="Remote/@ip"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="Remote/@port"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Error - </xsl:text>
		<xsl:value-of select="SocketError"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="RedirectError">
		<xsl:text>Error on node </xsl:text>
		<xsl:value-of select="@commsAddress"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="ModuleError"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="OsError"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>