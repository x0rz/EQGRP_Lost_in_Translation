<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="FileStart">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Receiving file </xsl:text>
		<xsl:value-of select="@fileId"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="@remoteName"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Size : </xsl:text>
		<xsl:value-of select="@size"/>
		<xsl:text> bytes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="LocalGetDirectory" />
 
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
		<xsl:if test="@status = 'SKIPPED'">
			<xsl:text>    File get operation skipped</xsl:text>
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

	<xsl:template match="Conclusion">
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="@successFiles" />
		<xsl:text> Files retrieved.</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="@partialFiles" />
		<xsl:text> Partial Files retrieved.</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="@failedFiles" />
		<xsl:text> Files transfers failed.</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="@skippedFiles" />
		<xsl:text> Files skipped. </xsl:text>
		<xsl:call-template name = "PrintReturn" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Total bytes written </xsl:text>
		<xsl:value-of select="@bytesTransferred" />
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>