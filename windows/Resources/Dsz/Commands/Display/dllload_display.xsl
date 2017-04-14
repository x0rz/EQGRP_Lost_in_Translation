<?xml version='1.1' ?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl" />
	
	<xsl:template match="Dll">
		<xsl:text>     Dll : </xsl:text>
		<xsl:value-of select="@name" />
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>Dll Size : </xsl:text>
		<xsl:value-of select="@size" />
		<xsl:text> bytes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="DllSend">
		<xsl:text>--Sending </xsl:text>
		<xsl:value-of select="@chunkSize" />
		<xsl:text> of </xsl:text>
		<xsl:value-of select="@totalSize" />
		<xsl:text> total bytes</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="DllLoad">
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Dll loaded at </xsl:text>
		<xsl:value-of select="@loadAddress" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="DllUnload">
		<xsl:text>Dll </xsl:text>
		<xsl:if test="@unloaded != 'true'">
			<xsl:text>NOT </xsl:text>
		</xsl:if>
		<xsl:text>unloaded</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="DllInjected">
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Dll injected into </xsl:text>
		<xsl:value-of select="@pid" />
		<xsl:call-template name="PrintReturn" />
		
		<xsl:text>    Load Address : </xsl:text>
		<xsl:value-of select="@loadAddress" />
		<xsl:call-template name="PrintReturn" />
		
		<xsl:text>        Unloaded : </xsl:text>
		<xsl:choose>
			<xsl:when test="@unloaded = 'true'">
				<xsl:text>YES</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NO</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />

		<xsl:call-template name="PrintReturn" />
	</xsl:template>

</xsl:transform>