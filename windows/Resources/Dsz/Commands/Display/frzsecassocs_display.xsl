<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="FrzSecAssocsActionCompleted">
		<xsl:text>Action completed</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="FrzSecAssocs">
		<xsl:text> Found </xsl:text>
		<xsl:value-of select="@numSecAssocs"/>
		<xsl:text> Security Associations : </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>   SRC                  DST              FLAGS</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>--------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="SecAssoc"/>
	</xsl:template>

	<xsl:template match="SecAssoc">
		<xsl:text> </xsl:text>
		<xsl:value-of select="@srcAddr"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="18-string-length(@srcAddr)"/>
		</xsl:call-template>
		<xsl:value-of select="@dstAddr"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="18-string-length(@dstAddr)"/>
		</xsl:call-template>
		<xsl:if test="FlagReceive">
			<xsl:text> IS_RECEIVE</xsl:text>
		</xsl:if>
		<xsl:if test="FlagSequenceCycle">
			<xsl:text> SEQUENCE_CYCLE</xsl:text>
		</xsl:if>
		<xsl:if test="FlagUseReplayPrevention">
			<xsl:text> USE_REPLAY_PREVENTION</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="FrzSecAssoc">
		<xsl:text>Key Exchange :</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>        Provider : </xsl:text>
		<xsl:value-of select="KeyExchange/@provider"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="KeyExchange/@providerName"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="string-length(KeyExchange/Parameters) > 0">
			<xsl:text>      Parameters : </xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:call-template name="PrintBinary">
				<xsl:with-param name="data" select="KeyExchange/Parameters"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Verification :</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>        Provider : </xsl:text>
		<xsl:value-of select="Verification/@provider"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="Verification/@providerName"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>            Type : </xsl:text>
		<xsl:value-of select="Verification/@typeName"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="string-length(Verification/Parameters) > 0">
			<xsl:text>      Parameters : </xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:call-template name="PrintBinary">
				<xsl:with-param name="data" select="Verification/Parameters"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Privacy :</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>        Provider : </xsl:text>
		<xsl:value-of select="Privacy/@provider"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="Privacy/@providerName"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="string-length(Privacy/Parameters) > 0">
			<xsl:text>      Parameters : </xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:call-template name="PrintBinary">
				<xsl:with-param name="data" select="Privacy/Parameters"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Key Update :</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>        Provider : </xsl:text>
		<xsl:value-of select="KeyUpdate/@provider"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="KeyUpdate/@providerName"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="string-length(KeyUpdate/Parameters) > 0">
			<xsl:text>      Parameters : </xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:call-template name="PrintBinary">
				<xsl:with-param name="data" select="KeyUpdate/Parameters"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Sequence Numbers : </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         Current : </xsl:text>
		<xsl:value-of select="SequenceNumber"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         Maximum : </xsl:text>
		<xsl:value-of select="SequenceNumberMax"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
 
</xsl:transform>