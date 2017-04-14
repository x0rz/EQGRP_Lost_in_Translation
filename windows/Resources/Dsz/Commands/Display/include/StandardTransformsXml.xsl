<?xml version='1.1' ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="StandardFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:element name="Xml">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:call-template name="PrintXml"/>
	</xsl:template>

	<xsl:template match="Echo">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="@type"/>
			<xsl:with-param name="text">
				<xsl:choose>
					<xsl:when test="@raw">
						<xsl:value-of select="."/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>- </xsl:text>
						<xsl:value-of select="."/>
						<xsl:call-template name="PrintReturn"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Autoload">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Autoloading plugin </xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text> (addr=</xsl:text>
				<xsl:value-of select="@target"/>
				<xsl:text>)</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="Errors">
		<xsl:if test="ModuleError">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Error'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="ModuleError"/>
					<xsl:call-template name="PrintReturn"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="OsError">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Error'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="OsError"/>
					<xsl:call-template name="PrintReturn"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ErrorString">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Error'"/>
			<xsl:with-param name="text">
				<xsl:text>* </xsl:text>
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="ModuleError">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Error'"/>
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="OsError">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Error'"/>
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="Exception">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Error'"/>
			<xsl:with-param name="text">
				<xsl:text>*************************************************************************&#x0A;</xsl:text>
				<xsl:text>*&#x0A;</xsl:text>
				<xsl:text>* Task </xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text> has exited by an exception&#x0A;</xsl:text>
				<xsl:text>*&#x0A;</xsl:text>
				<xsl:text>*************************************************************************&#x0A;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="Cancelled">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Warning'"/>
			<xsl:with-param name="text">
				<xsl:text>&#x0A;    *** Command cancelled ***&#x0A;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="Failure">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Warning'"/>
			<xsl:with-param name="text">
				<xsl:text>&#x0A;    *** Command indicated failure ***&#x0A;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="Success">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>&#x0A;    Command completed successfully&#x0A;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Info">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="IntermediateSuccess">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:text>Command </xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text> indicated success and will continue to run in the background&#x0A;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
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
	
  <!-- FUNCTIONS -->

	<!--
		PrintXml()
		    Prints the current node as XML
	-->
	<xsl:template name="PrintXml">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="Error"/>
			<xsl:with-param name="text">
				<xsl:text>&lt;</xsl:text>
				<xsl:value-of select="name(.)"/>
				<xsl:text> ...&gt;</xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name(.)"/>
				<xsl:text>&gt;&#x0A;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="XmlOutput">
		<xsl:param name="text" select="''"/>
		<xsl:param name="type" select="'Default'"/>
		
		<xsl:element name="Node">
			<xsl:attribute name="type">
				<xsl:value-of select="$type"/>
			</xsl:attribute>
			<xsl:value-of select="$text"/>
		</xsl:element>
		
	</xsl:template>

</xsl:stylesheet>
