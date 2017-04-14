<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="StandardTransforms.xsl"/>
	<xsl:output method="text"/>
	
	<xsl:template match="RawData"/>
	<xsl:template match="Strings"/>
	
	<xsl:template match="PerformanceInformation">
		<xsl:text>Performance data for </xsl:text>
		<xsl:value-of select="@systemName"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="ObjectType">
			<xsl:with-param name="perfTime" select="@perfTime"/>
			<xsl:with-param name="perfFreq" select="@perfFreq"/>
			<xsl:with-param name="perfTime100nSec" select="@perfTime100nSec"/>
		</xsl:apply-templates>
		<!--
		<xsl:text>Perf Time: </xsl:text>
		<xsl:value-of select="@perfTime"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Perf Freq: </xsl:text>
		<xsl:value-of select="@perfFreq"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Perf Time 100n: </xsl:text>
		<xsl:value-of select="@perfTime100nSec"/>
		-->
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="ObjectType">
		<xsl:param name="perfTime"/>
		<xsl:param name="perfFreq"/>
		<xsl:param name="perfTime100nSec"/>
		
		<xsl:value-of select="Name"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="Help"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="contains(name(.), 'Instance')">
					<xsl:call-template name="PrintInstance">
						<xsl:with-param name="perfTime" select="$perfTime"/>
						<xsl:with-param name="perfFreq" select="$perfFreq"/>
						<xsl:with-param name="perfTime100nSec" select="$perfTime100nSec"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="contains(name(.), 'Counter')">
					<xsl:call-template name="PrintCounter">
						<xsl:with-param name="perfTime" select="$perfTime"/>
						<xsl:with-param name="perfFreq" select="$perfFreq"/>
						<xsl:with-param name="perfTime100nSec" select="$perfTime100nSec"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="PrintInstance">
		<xsl:param name="perfTime"/>
		<xsl:param name="perfFreq"/>
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
				<xsl:with-param name="perfTime" select="$perfTime"/>
				<xsl:with-param name="perfFreq" select="$perfFreq"/>
				<xsl:with-param name="perfTime100nSec" select="$perfTime100nSec"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="PrintCounter">
		<xsl:param name="i" select="2"/>
		<xsl:param name="perfTime"/>
		<xsl:param name="perfFreq"/>
		<xsl:param name="perfTime100nSec"/>
		<xsl:choose>
			<xsl:when test="contains(Value/@type, 'PERF_COUNTER_COUNTER')"/>
			<xsl:when test="contains(Value/@type, 'PERF_COUNTER_BULK_COUNT')"/>
			<xsl:when test="contains(Value/@type, 'PERF_AVERAGE_TIMER')"/>
			<xsl:when test="contains(Value/@type, 'PERF_AVERAGE_BASE')"/>
			<xsl:when test="contains(Value/@type, 'PERF_PRECISION_100NS_TIMER')"/>
			<xsl:when test="contains(Value/@type, 'PERF_COUNTER_100NS_QUEUELEN_TYPE')"/>
			<xsl:when test="contains(Value/@type, 'PERF_LARGE_RAW_BASE')"/>
			<xsl:when test="contains(Value/@type, 'PERF_RAW_FRACTION')"/>
			<xsl:when test="contains(Value/@type, 'PERF_100NSEC_TIMER')"/>
			<xsl:when test="contains(Value/@type, 'PERF_ELAPSED_TIME')">
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="$i"/>
				</xsl:call-template>
				<xsl:value-of select="Name"/>
				<xsl:text>:  </xsl:text>
				<xsl:value-of select="($perfTime100nSec - Value/@value) div (10*1000*1000)"/>
				<xsl:text> sec</xsl:text>
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
		<xsl:value-of select="@value"/>
		<!--
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@type"/>
		<xsl:text>)</xsl:text>
		-->
	</xsl:template>
</xsl:transform>
