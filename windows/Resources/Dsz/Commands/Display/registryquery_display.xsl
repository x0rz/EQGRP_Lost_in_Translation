<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Keys">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="Key">
		<xsl:text>______________________________________________________________</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	
		<xsl:value-of select="substring-before(LastUpdate, 'T')"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="substring-before(substring-after(LastUpdate, 'T'), '.')"/>
		
		<xsl:choose>
			<xsl:when test="@hive = 'HKEY_LOCAL_MACHINE'"> L </xsl:when>
			<xsl:when test="@hive = 'HKEY_USERS'"> U </xsl:when>
			<xsl:when test="@hive = 'HKEY_CLASSES_ROOT'"> R </xsl:when>
			<xsl:when test="@hive = 'HKEY_CURRENT_USER'"> C </xsl:when>
			<xsl:when test="@hive = 'HKEY_CURRENT_CONFIG'"> G </xsl:when>
			<xsl:otherwise> ? </xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="@name"/>
		<xsl:text>\</xsl:text>

		<xsl:if test="string-length(@class) != 0">
			<xsl:text> (class=</xsl:text>
			<xsl:value-of select="@class"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
    
		<xsl:if test="@denied = 'true'">
			<xsl:text>    ACCESS_DENIED</xsl:text>
		</xsl:if>

		<xsl:apply-templates select="Subkey"/>
		<xsl:apply-templates select="Value"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Subkey">
		<xsl:text>  </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>\</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Value">
		<xsl:text>    </xsl:text>
		<xsl:choose>
			<xsl:when test="string-length(@name) = 0">
				<xsl:text>(Default)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@name"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> (</xsl:text><xsl:value-of select="@type"/><xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:choose>
			<xsl:when test="(@type = 'REG_EXPAND_SZ') or 
							(@type = 'REG_SZ') or
							(@type = 'REG_DWORD') or 
							(@type = 'REG_DWORD_BIG_ENDIAN') or
							(@type = 'REG_QWORD') or
							(@type = 'REG_QWORD_BIG_ENDIAN')">
				<xsl:text>        </xsl:text>
				<xsl:choose>
					<xsl:when test="Translated">
						<xsl:value-of select="Translated"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="Raw"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="PrintReturn"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- BINARY -->
				<xsl:call-template name="PrintBinary">
					<xsl:with-param name="data" select="Raw"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Success">
		<xsl:text>Registry query complete</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>