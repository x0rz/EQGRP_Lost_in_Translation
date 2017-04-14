<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="include/StandardTransforms.xsl" />
	<xsl:template match="Devices">
		<xsl:apply-templates select="Device" />
	</xsl:template>
	<xsl:template match="Device">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>______________________________________________________________</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    DeviceDesc:       </xsl:text>
		<xsl:value-of select="DeviceDesc" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Driver:           </xsl:text>
		<xsl:value-of select="Driver" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    FriendlyName:     </xsl:text>
		<xsl:value-of select="FriendlyName" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    HwdID(1st string):</xsl:text>
		<xsl:value-of select="HardwareId" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    LocationInfo:     </xsl:text>
		<xsl:value-of select="LocationInfo" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Mfg:              </xsl:text>
		<xsl:value-of select="Mfg" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    PhysDevObjName:   </xsl:text>
		<xsl:value-of select="PhysDevObjName" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    ServPth:          </xsl:text>
		<xsl:value-of select="ServicePath" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>