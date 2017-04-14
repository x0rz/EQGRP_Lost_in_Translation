<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="include/StandardTransforms.xsl" />
	<xsl:output method="text" />
	
	<xsl:template match="Drives">
		<xsl:apply-templates select="Drive"/>
	</xsl:template>
	
	<xsl:template match="Drive">
		<xsl:text>----------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:value-of select="Path" />
		<xsl:call-template name="PrintReturn" />
		
		<xsl:text>         Type : </xsl:text>
		<xsl:value-of select="Type" />
		<xsl:call-template name="PrintReturn" />
		
		<xsl:if test="FileSystem">
			<xsl:text>  File System : </xsl:text>
			<xsl:value-of select="FileSystem" />
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Source">
			<xsl:text>       Device : </xsl:text>
			<xsl:value-of select="Source" />
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		
		<xsl:if test="Flags">
			<!-- print a few of the flags -->
			<xsl:text>        Flags : </xsl:text>
			<xsl:choose>
				<xsl:when test="Flags/DriveFlagWritePermission">Read-Write </xsl:when>
				<xsl:when test="Flags/DriveFlagReadPermission">Read-Only</xsl:when>
			</xsl:choose>
			<xsl:if test="Flags/DriveFlagIsCompressed">Compressed </xsl:if>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		
		<xsl:if test="Options">
			<xsl:choose>
				<xsl:when test="(string-length(Path) = 3) and contains(Path, ':')">
					<xsl:text> Volume Label : </xsl:text>
					<xsl:value-of select="Options"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Mount Options : </xsl:text>
					<xsl:value-of select="Options"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		
		<xsl:if test="SerialNumber">
			<xsl:text>Serial Number : </xsl:text>
			<xsl:value-of select="SerialNumber"/>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
	</xsl:template>

</xsl:transform>
