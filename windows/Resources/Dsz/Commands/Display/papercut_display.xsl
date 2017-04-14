<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="LocalGetDirectory"/>
  
	<xsl:template match="FileStart">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Receiving file </xsl:text>
		<xsl:value-of select="@remoteName"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Size : </xsl:text>
		<xsl:value-of select="@filesize"/>
		<xsl:text> bytes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="SetEnv" />
	
	<xsl:template match="FileLocalName">
		<xsl:text>    Storing to : </xsl:text>
		<xsl:value-of select="@subdir"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="FileWrite">
		<xsl:text>Writing </xsl:text>
		<xsl:value-of select="@bytes"/>
		<xsl:text> bytes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="FileStop">
		<xsl:if test="@status = 'SUCCESS'">
			<xsl:text>    File get operation succeeded</xsl:text>
		    <xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:text>    Stored: </xsl:text>
		<xsl:value-of select="@bytesWritten"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@status"/>
		<xsl:if test="@statusValue">
			<xsl:text> - </xsl:text>
			<xsl:value-of select="@statusValue"/>
		</xsl:if>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="StatusString">
			<xsl:text>      (</xsl:text>
			<xsl:value-of select="StatusString"/>
			<xsl:text>)</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="FileLock">
		<xsl:text>File: </xsl:text>
		<xsl:value-of select="@filename"/>
		<xsl:text> locked for </xsl:text>

		<xsl:call-template name="printTime">
			<xsl:with-param name="time" select="LockDuration"/>
			<xsl:with-param name="formatDelta" select="'true'"/>
		</xsl:call-template>

		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="FileTrim">
		<xsl:text>Trimmed </xsl:text>
		<xsl:value-of select="@bytesRemoved"/>
		<xsl:text> bytes from </xsl:text>
		<xsl:value-of select="@filename"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="FileMap">
		<xsl:text>File: </xsl:text>
		<xsl:value-of select="@filename"/>
		<xsl:choose>
			<xsl:when test="@pid &gt; 0">
				<xsl:text> is memory mapped by PID: </xsl:text>
				<xsl:value-of select="@pid"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> is not memory mapped</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>