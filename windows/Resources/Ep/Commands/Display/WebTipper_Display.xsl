<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="StandardTransforms.xsl"/>
	<xsl:output method="text"/>

	<xsl:template match="Status">
		<xsl:text>Packet Scanning : </xsl:text>
		<xsl:choose>
			<xsl:when test="@filterActive = 'true'">
				<xsl:text>ENABLED</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>DISABLED</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text> Thread Running : </xsl:text>
		<xsl:choose>
			<xsl:when test="@threadRunning = 'true'">
				<xsl:text>YES</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NO</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
  
		<xsl:text>       Mailslot : </xsl:text>
		<xsl:value-of select="@mailslotName"/>
		<xsl:call-template name="PrintReturn"/>
  
		<xsl:text>  # of Patterns : </xsl:text>
	    <xsl:value-of select="@numPatterns"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:apply-templates select="Pattern"/>
	</xsl:template>

	<xsl:template match="Pattern">
		<xsl:text>--------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>&#09;        Type : </xsl:text>
		<xsl:value-of select="@type"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>&#09;Host or Type : </xsl:text>
		<xsl:value-of select="@host"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>&#09;   Pattern 1 : </xsl:text>
		<xsl:value-of select="@pattern1"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>&#09;   Pattern 2 : </xsl:text>
		<xsl:value-of select="@pattern2"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Filter">
		<!-- print adapter filter -->
		<xsl:apply-templates select="AdapterFilter"/>
		<xsl:call-template name="PrintReturn"/>

		<!-- print capture filter -->
		<xsl:text>Filter Length: </xsl:text>
		<xsl:value-of select="Filter/@length"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:for-each select="BpfFilterInstructions/Instruction">
			<xsl:text> </xsl:text>
			<xsl:value-of select="format-number(position(), '0000')"/>
			<xsl:text> - </xsl:text>
			<xsl:value-of select="."/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="Success">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Command completed successfully</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="AdapterFilter">
		<xsl:text>Adapter Filter: (</xsl:text>
		<xsl:value-of select="@value"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:if test="NdisPacketTypeDirected">
			<xsl:text>    DIRECTED</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeMulticast">
			<xsl:text>    MULTICAST</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeAllMulticast">
			<xsl:text>    ALL MULTICAST</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeBroadcast">
			<xsl:text>    BROADCAST</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeSourceRouting">
			<xsl:text>    SOURCE ROUTING</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypePromiscuous">
			<xsl:text>    PROMISCUOUS</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeSmt">
			<xsl:text>    SMT</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeAllLocal">
			<xsl:text>    ALL LOCAL</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeMacFrame">
			<xsl:text>    MAC FRAME</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeFunctional">
			<xsl:text>    FUNCTIONAL</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeAllFunctional">
			<xsl:text>    ALL FUNCTIONAL</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="NdisPacketTypeGroup">
			<xsl:text>    GROUP</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>

</xsl:transform>