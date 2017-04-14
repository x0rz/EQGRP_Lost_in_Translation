<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="eventlogquery_common.xsl" />
	
	<xsl:template match="EventLog">
		<xsl:text>The </xsl:text>
		<xsl:value-of select="@name" />
		<xsl:text> event log contains </xsl:text>
		<xsl:value-of select="@numRecords" />
		<xsl:text> record(s).</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>&#x09;Most recent entry is dated </xsl:text>
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="dateTime" select="Time" />
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:call-template name="PrintTime">
			<xsl:with-param name="dateTime" select="Time" />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>&#x09;Oldest Record Number      = </xsl:text>
		<xsl:value-of select="@oldestRecordNum" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>&#x09;Most Recent Record Number = </xsl:text>
		<xsl:value-of select="@mostRecentRecordNum" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="ErrLog">
		<xsl:text>Failed to query the </xsl:text>
		<xsl:value-of select="@name" />
		<xsl:text> event log</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Win32 error : </xsl:text>
		<xsl:value-of select="@osError" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
</xsl:transform>
