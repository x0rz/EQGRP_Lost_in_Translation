<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="StandardFunctions.xsl"/>
	<xsl:output method="text"/>

	<xsl:template match="Errors">
		<xsl:if test="ModuleError">
			<xsl:value-of select="ModuleError"/>
			<xsl:text>&#x0A;</xsl:text>
		</xsl:if>
		<xsl:if test="OsError">
			<xsl:value-of select="OsError"/>
			<xsl:text>&#x0A;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ErrorString">
		<xsl:text>*&#x0A;</xsl:text>
		<xsl:text>* Error: </xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>&#x0A;*&#x0A;</xsl:text>
	</xsl:template>

	<xsl:template match="ModuleError">
		<xsl:value-of select="."/>
		<xsl:text>&#x0A;</xsl:text>
	</xsl:template>

	<xsl:template match="OsError">
		<xsl:value-of select="."/>
		<xsl:text>&#x0A;</xsl:text>
	</xsl:template>

	<xsl:template match="Exception">
		<xsl:text>*************************************************************************&#x0A;</xsl:text>
		<xsl:text>*&#x0A;</xsl:text>
		<xsl:text>* Task </xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text> encountered an exception&#x0A;</xsl:text>
		<xsl:text>*&#x0A;</xsl:text>
		<xsl:text>*************************************************************************&#x0A;</xsl:text>
	</xsl:template>

	<xsl:template match="Cancelled">
		<xsl:text>&#x0A;    *** Command cancelled ***&#x0A;</xsl:text>
	</xsl:template>
	<xsl:template match="Failure">
		<xsl:text>&#x0A;    *** Command indicated failure ***&#x0A;</xsl:text>
	</xsl:template>
	<xsl:template match="Success">
		<xsl:text>&#x0A;    Command completed successfully&#x0A;</xsl:text>
	</xsl:template>

	<xsl:template match="Info">
		<xsl:value-of select="."/>
		<xsl:text>&#x0A;</xsl:text>
	</xsl:template>

	<xsl:template match="Echo">
		<xsl:value-of select="."/>
		<xsl:text>&#x0A;</xsl:text>
	</xsl:template>
	
	<xsl:template match="IntermediateSuccess">
		<xsl:text>Command </xsl:text>
		<xsl:value-of select="@request"/>
		<xsl:text> indicated success and will continue to run in the background&#x0A;</xsl:text>
	</xsl:template>

	<!-- by default, ignore these elements -->
	<xsl:template match="Alias"/>
	<xsl:template match="Command"/>
	<xsl:template match="Instance"/>
	<xsl:template match="Target"/>
	<xsl:template match="CtrlC"/>
	<xsl:template match="Debug"/>
	<xsl:template match="TaskingInfo"/>
	<xsl:template match="TaskResult"/>
	<xsl:template match="SetEnv"/>
	
	<xsl:template match="text()">
		<xsl:value-of select="." />
	</xsl:template>
	
	<xsl:template match="node()">
		<xsl:param name="spaces" select="0"/>
		
		<xsl:choose>
			<xsl:when test="string-length(local-name(.)) &gt; 0 ">
				<xsl:text></xsl:text>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="$spaces"/>
				</xsl:call-template>
				<xsl:text>&lt;</xsl:text>
				<xsl:value-of select="local-name(.)"/>
				<xsl:apply-templates select="@*"/>
				<xsl:choose>
					<xsl:when test="node()">
						<xsl:text>&gt;</xsl:text>
						<xsl:apply-templates select="node()">
							<xsl:with-param name="spaces" select="number($spaces)+1" />
						</xsl:apply-templates>
						
						<xsl:call-template name="Whitespace">
							<xsl:with-param name="i" select="$spaces"/>
						</xsl:call-template>
						
						<xsl:text>&lt;/</xsl:text>
						<xsl:value-of select="local-name(.)"/>
						<xsl:text>&gt;</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>/&gt;</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<!--
				<xsl:call-template name="PrintReturn"/> 
				-->
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@*">
		<xsl:text> </xsl:text>
		<xsl:value-of select="name(.)"/>
		<xsl:text>="</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	
</xsl:transform>
