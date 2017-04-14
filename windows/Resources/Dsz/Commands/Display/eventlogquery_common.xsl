<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="include/StandardTransforms.xsl" />
	<xsl:import href="include/StandardFunctions.xsl" />
	
	<xsl:template match="Records">
		<xsl:text> Rec #      Type         Date      Time     EvtID    Computer     Source</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>-------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="Record" />
	</xsl:template>
	
	<xsl:template match="Record">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="5 - string-length(@number)" />
		</xsl:call-template>
		<xsl:value-of select="@number" />
		<xsl:text>: </xsl:text>
		<xsl:value-of select="@eventType" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="16 - string-length(@eventType)" />
		</xsl:call-template>
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="dateTime" select="TimeWritten" />
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:call-template name="PrintTime">
			<xsl:with-param name="dateTime" select="TimeWritten" />
		</xsl:call-template>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="6 - string-length(@code)" />
		</xsl:call-template>
		<xsl:value-of select="@code" />
		<xsl:text> </xsl:text>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="13 - string-length(@computer)" />
		</xsl:call-template>
		<xsl:value-of select="@computer" />
		<xsl:text> </xsl:text>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="12 - string-length(@source)" />
		</xsl:call-template>
		<xsl:value-of select="@source" />
		<xsl:call-template name="PrintReturn" />
		<!-- if we're only looking at a few events, print extra info -->
		<xsl:if test="30 > count(../Event)">
			<xsl:text>&#09;Sid : </xsl:text>
			<!--<xsl:call-template name="PrintReturn" /> -->
			<xsl:text>&#09;    </xsl:text>
			<xsl:value-of select="@sid" />
			<xsl:call-template name="PrintReturn" />
			<xsl:if test="String">
				<xsl:call-template name="PrintReturn" />
				<xsl:text>&#09;Strings :</xsl:text>
				<xsl:call-template name="PrintReturn" />
				<xsl:apply-templates select="String" />
			</xsl:if>
			<xsl:if test="Data">
				<xsl:call-template name="PrintReturn" />
				<xsl:text>&#09;Data :</xsl:text>
				<xsl:call-template name="PrintReturn" />
				<xsl:call-template name="PrintBinary">
					<xsl:with-param name="data" select="Data"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="String">
		<xsl:text>&#09;    </xsl:text>
		<xsl:value-of select="." />
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template name="PrintDate">
		<xsl:param name="dateTime" />
	
		<xsl:value-of select="substring-before($dateTime, 'T')" />
	</xsl:template>
	
	<xsl:template name="PrintTime">
		<xsl:param name="dateTime" />
		<xsl:value-of select="substring-before(substring-after($dateTime, 'T'), '.')" />
	</xsl:template>
	
</xsl:transform>
