<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="PerformanceHeader">
		<xsl:text>Performance data for </xsl:text>
		<xsl:value-of select="@systemName"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>      Perf Count: </xsl:text>
		<xsl:value-of select="@perfCount"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Perf Counts /sec: </xsl:text>
		<xsl:value-of select="@perfCountsPerSecond"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>  Perf Time 100n: </xsl:text>
		<xsl:value-of select="@perfTime100nSec"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:apply-templates select="ObjectHeader">
			<xsl:with-param name="perfCountPerSec" select="@perfCountsPerSecond"/>
			<xsl:with-param name="perfCount" select="@perfCount"/>
			<xsl:with-param name="perfTime100nSec" select="@perfTime100nSec"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="ObjectHeader">
		<xsl:param name="perfCountPerSec"/>
		<xsl:param name="perfCount"/>
		<xsl:param name="perfTime100nSec"/>
		
		<xsl:text>-----------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="Name"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="Help"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="contains(name(.), 'Instance')">
					<xsl:call-template name="PrintInstance">
						<xsl:with-param name="perfCountPerSec" select="$perfCountPerSec"/>
						<xsl:with-param name="perfCount" select="$perfCount"/>
						<xsl:with-param name="perfTime100nSec" select="$perfTime100nSec"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="contains(name(.), 'Counter')">
					<xsl:call-template name="PrintCounter">
						<xsl:with-param name="perfCountPerSec" select="$perfCountPerSec"/>
						<xsl:with-param name="perfCount" select="$perfCount"/>
						<xsl:with-param name="perfTime100nSec" select="$perfTime100nSec"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="PrintInstance">
		<xsl:param name="perfCountPerSec"/>
		<xsl:param name="perfCount"/>
		<xsl:param name="perfTime100nSec"/>
		<xsl:param name="i" select="2"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="$i"/>
		</xsl:call-template>
		<xsl:value-of select="@name"/>
		<xsl:if test="@parentInstance &gt; -1">
			<xsl:text> (Parent </xsl:text>
			<xsl:value-of select="@parentInstance"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
		<xsl:for-each select="Counter">
			<xsl:call-template name="PrintCounter">
				<xsl:with-param name="i" select="$i + 2" />
				<xsl:with-param name="perfCountPerSec" select="$perfCountPerSec"/>
				<xsl:with-param name="perfCount" select="$perfCount"/>
				<xsl:with-param name="perfTime100nSec" select="$perfTime100nSec"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="PrintCounter">
		<xsl:param name="i" select="2"/>
		<xsl:param name="perfCountPerSec"/>
		<xsl:param name="perfCount"/>
		<xsl:param name="perfTime100nSec"/>
		<xsl:choose>
			<xsl:when test="contains(Value/@type, 'PERF_ELAPSED_TIME')">
				<xsl:variable name="Seconds" select="floor(($perfTime100nSec - Value) div (10*1000*1000))"/>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="$i"/>
				</xsl:call-template>
				<xsl:value-of select="Name"/>
				<xsl:text>:  </xsl:text>
				<xsl:value-of select="floor($Seconds div (3600 * 24))"/>
				<xsl:text> Day(s), </xsl:text>
				<xsl:value-of select="floor(($Seconds mod (3600 * 24)) div 3600)"/>
				<xsl:text> Hour(s), </xsl:text>
				<xsl:value-of select="floor(($Seconds mod (3600)) div 60)"/>
				<xsl:text> Minute(s), </xsl:text>
				<xsl:value-of select="$Seconds mod 60"/>
				<xsl:text> Second(s), </xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="$i"/>
				</xsl:call-template>
				<xsl:value-of select="Name"/>
				<xsl:text>:  </xsl:text>
				<xsl:apply-templates select="Value"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Value">
		<xsl:value-of select="."/>
		<!--
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@type"/>
		<xsl:text>)</xsl:text>
		-->
	</xsl:template>

</xsl:transform>