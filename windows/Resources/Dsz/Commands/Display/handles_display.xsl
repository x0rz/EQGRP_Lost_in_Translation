<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="ClosedHandle">
		<xsl:text>Closed handle </xsl:text>
		<xsl:value-of select="@handleId"/>
		<xsl:text> in process </xsl:text>
		<xsl:value-of select="@processId"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="DuplicatedHandle">
		<xsl:text>Duplicated handle </xsl:text>
		<xsl:value-of select="@origHandleId"/>
		<xsl:text> from process </xsl:text>
		<xsl:value-of select="@origProcessId"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:call-template name="PrintReturn"/>
		<xsl:text>New handle:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>  Process Id : </xsl:text>
		<xsl:value-of select="@newProcessId"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>   Handle Id : </xsl:text>
		<xsl:value-of select="@newHandleId"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Handles">
		<xsl:apply-templates select="Process"/>
	</xsl:template>

	<xsl:template match="Process">
		<xsl:text>----------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Process: </xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>----------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:apply-templates select="Handle"/>
	</xsl:template>

	<xsl:template match="Handle">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="6 - string-length(@handleId)" />
		</xsl:call-template>
		<xsl:value-of select="@handleId"/>
		<xsl:text>: </xsl:text>
		<xsl:value-of select="@type"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:if test="string-length(Metadata) &gt; 0">
			<xsl:text>      </xsl:text>
			<xsl:value-of select="Metadata"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
</xsl:transform>