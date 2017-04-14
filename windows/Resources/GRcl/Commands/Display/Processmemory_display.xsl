<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
    <xsl:template match="ExtractedRegion">
        <xsl:text>Memory Filename:</xsl:text>
        <xsl:value-of select="LocalFileName" />
        <xsl:call-template name="PrintReturn" />

        <xsl:text>Process:</xsl:text>
        <xsl:value-of select="ProcessName" />
        <xsl:call-template name="PrintReturn" />

        <xsl:text>Size of extracted data:</xsl:text>
        <xsl:value-of select="@Size" />
        <xsl:call-template name="PrintReturn" />
    </xsl:template>

<xsl:template match="MemorySnapshot">
    <xsl:apply-templates select="MemoryRegion"/>
</xsl:template>

<xsl:template match="MemoryRegion">
    <xsl:text></xsl:text>
    <xsl:value-of select="@AllocationBase" />

    <xsl:text> : </xsl:text>
    <xsl:value-of select="@BaseAddress" />

    <xsl:text> - </xsl:text>
    <xsl:value-of select="@RegionSize" />

    <xsl:call-template name="PrintReturn" />

    <xsl:call-template name="Whitespace">
        <xsl:with-param name="i" select="5" />
    </xsl:call-template>

    <!-- TYPE -->
    <xsl:text>Type      </xsl:text>
    <xsl:value-of select="@Type" />
    <xsl:apply-templates select="Type"/>
    <xsl:call-template name="PrintReturn" />

    <xsl:call-template name="Whitespace">
        <xsl:with-param name="i" select="5" />
    </xsl:call-template>

    <!-- PROTECT -->
    <xsl:text>Protect   </xsl:text>
    <xsl:value-of select="@Protect" />
    <xsl:apply-templates select="Protect"/>
    <xsl:call-template name="PrintReturn" />

    <xsl:call-template name="Whitespace">
        <xsl:with-param name="i" select="5" />
    </xsl:call-template>

    <!-- STATE -->
    <xsl:text>State     </xsl:text>
    <xsl:value-of select="@State" />
    <xsl:apply-templates select="State"/>
    <xsl:call-template name="PrintReturn" />

    <xsl:call-template name="Whitespace">
        <xsl:with-param name="i" select="5" />
    </xsl:call-template>

    <!-- USAGE -->
    <xsl:text>Usage     </xsl:text>
    <xsl:value-of select="@RegionUsageFlags" />
    <xsl:apply-templates select="RegionUsage"/>
    <xsl:call-template name="PrintReturn" />

    <xsl:if test="@ThreadId!='0x00000000'">
        <xsl:call-template name="Whitespace">
            <xsl:with-param name="i" select="5" />
        </xsl:call-template>

        <xsl:text>Thread Id </xsl:text>
        <xsl:value-of select="@ThreadId" />
        <xsl:call-template name="PrintReturn" />
    </xsl:if>

    <xsl:if test="SectionName!=''">
        <xsl:call-template name="Whitespace">
            <xsl:with-param name="i" select="5" />
        </xsl:call-template>

        <xsl:text>Section Name </xsl:text>
        <xsl:value-of select="SectionName" />
        <xsl:call-template name="PrintReturn" />
    </xsl:if>

    <xsl:if test="MappedFileName!=''">
        <xsl:call-template name="Whitespace">
            <xsl:with-param name="i" select="5" />
        </xsl:call-template>

        <xsl:text>Mapped Filename </xsl:text>
        <xsl:value-of select="MappedFileName" />
        <xsl:call-template name="PrintReturn" />
    </xsl:if>

    <xsl:call-template name="PrintReturn" />
    </xsl:template>

    <!-- TYPE TEMPLATE -->
    <xsl:template match="Type">
        <xsl:choose>
            <xsl:when test="count(descendant::*) > 0">
                <xsl:for-each select="descendant::*">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="name(.)" />
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> MEM_FREE</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- PROTECT TEMPLATE -->
    <xsl:template match="Protect">
        <xsl:choose>
            <xsl:when test="count(descendant::*) > 0">
                <xsl:for-each select="descendant::*">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="name(.)" />
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> UNKNOWN</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- STATE TEMPLATE -->
    <xsl:template match="State">
        <xsl:choose>
            <xsl:when test="count(descendant::*) > 0">
                <xsl:for-each select="descendant::*">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="name(.)" />
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> UNKNOWN</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- REGIONUSAGE TEMPLATE -->
    <xsl:template match="RegionUsage">
        <xsl:choose>
            <xsl:when test="count(descendant::*) > 0">
                <xsl:for-each select="descendant::*">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="name(.)" />
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:transform>
