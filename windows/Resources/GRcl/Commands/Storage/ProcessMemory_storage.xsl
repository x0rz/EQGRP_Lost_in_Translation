<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />

	<xsl:template match="/">
        <xsl:element name="StorageObjects">
            <xsl:apply-templates/> <!-- select="MemorySnapshot"/>-->
		</xsl:element>
	</xsl:template>

	<xsl:template match="ExtractedRegion">
		<xsl:element name="ObjectValue">
            <xsl:attribute name="name">ExtractedRegion</xsl:attribute>
            
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Size</xsl:attribute>
				<xsl:value-of select="@Size"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LocalfileName</xsl:attribute>
				<xsl:value-of select="LocalFileName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ProcessName</xsl:attribute>
				<xsl:value-of select="ProcessName"/>
            </xsl:element>

        </xsl:element>
	</xsl:template>


	<xsl:template match="MemorySnapshot">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">MemorySnapshot</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>

	<xsl:template match="MemoryRegion">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">MemoryRegion</xsl:attribute>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">BaseAddress</xsl:attribute>
				<xsl:value-of select="@BaseAddress"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">AllocationBase</xsl:attribute>
				<xsl:value-of select="@AllocationBase"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">AllocationProtect</xsl:attribute>
				<xsl:value-of select="@AllocationProtect"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">RegionSize</xsl:attribute>
				<xsl:value-of select="@RegionSize"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">State</xsl:attribute>
				<xsl:value-of select="@State"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Protect</xsl:attribute>
				<xsl:value-of select="@Protect"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="@Type"/>
			</xsl:element>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">RegionUsageFlags</xsl:attribute>
				<xsl:value-of select="@RegionUsageFlags"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ThreadId</xsl:attribute>
				<xsl:value-of select="@ThreadId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SectionName</xsl:attribute>
				<xsl:value-of select="SectionName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">MappedFileName</xsl:attribute>
				<xsl:value-of select="MappedFileName"/>
            </xsl:element>

            <xsl:apply-templates select="AllocationProtect"/>
            <xsl:apply-templates select="Protect"/>
            <xsl:apply-templates select="State"/>
            <xsl:apply-templates select="Type"/>
            <xsl:apply-templates select="RegionUsage"/>

        </xsl:element>
    </xsl:template>    



    <!-- ALLOCATION PROTECT -->
    <xsl:template match="AllocationProtect">
        <xsl:element name="ObjectValue">
            <xsl:attribute name="name">AllocationProtect</xsl:attribute>

            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_NOACCESS" />
                <xsl:with-param name="var" select="'PAGE_NOACCESS'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_READONLY" />
                <xsl:with-param name="var" select="'PAGE_READONLY'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_READWRITE" />
                <xsl:with-param name="var" select="'PAGE_READWRITE'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_WRITECOPY" />
                <xsl:with-param name="var" select="'PAGE_WRITECOPY'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_EXECUTE" />
                <xsl:with-param name="var" select="'PAGE_EXECUTE'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_EXECUTE_READ" />
                <xsl:with-param name="var" select="'PAGE_EXECUTE_READ'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_EXECUTE_READWRITE" />
                <xsl:with-param name="var" select="'PAGE_EXECUTE_READWRITE'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_EXECUTE_WRITECOPY" />
                <xsl:with-param name="var" select="'PAGE_EXECUTE_WRITECOPY'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_GUARD" />
                <xsl:with-param name="var" select="'PAGE_GUARD'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_NOCACHE" />
                <xsl:with-param name="var" select="'PAGE_NOCACHE'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_WRITECOMBINE" />
                <xsl:with-param name="var" select="'PAGE_WRITECOMBINE'" />
            </xsl:call-template>

        </xsl:element>
    </xsl:template>

    <!-- PROTECT -->
    <xsl:template match="Protect">
        <xsl:element name="ObjectValue">
            <xsl:attribute name="name">Protect</xsl:attribute>

            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_NOACCESS" />
                <xsl:with-param name="var" select="'PAGE_NOACCESS'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_READONLY" />
                <xsl:with-param name="var" select="'PAGE_READONLY'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_READWRITE" />
                <xsl:with-param name="var" select="'PAGE_READWRITE'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_WRITECOPY" />
                <xsl:with-param name="var" select="'PAGE_WRITECOPY'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_EXECUTE" />
                <xsl:with-param name="var" select="'PAGE_EXECUTE'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_EXECUTE_READ" />
                <xsl:with-param name="var" select="'PAGE_EXECUTE_READ'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_EXECUTE_READWRITE" />
                <xsl:with-param name="var" select="'PAGE_EXECUTE_READWRITE'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_EXECUTE_WRITECOPY" />
                <xsl:with-param name="var" select="'PAGE_EXECUTE_WRITECOPY'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_GUARD" />
                <xsl:with-param name="var" select="'PAGE_GUARD'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_NOCACHE" />
                <xsl:with-param name="var" select="'PAGE_NOCACHE'" />
            </xsl:call-template>
            <xsl:call-template  name="Protect">
                <xsl:with-param name="flag" select="PAGE_WRITECOMBINE" />
                <xsl:with-param name="var" select="'PAGE_WRITECOMBINE'" />
            </xsl:call-template>

        </xsl:element>
    </xsl:template>

    <!-- STATE -->
    <xsl:template match="State">
        <xsl:element name="ObjectValue">
            <xsl:attribute name="name">State</xsl:attribute>
            <xsl:call-template  name="State">
                <xsl:with-param name="flag" select="MEM_COMMIT" />
                <xsl:with-param name="var" select="'MEM_COMMIT'" />
            </xsl:call-template>
            <xsl:call-template  name="State">
                <xsl:with-param name="flag" select="MEM_RESERVE" />
                <xsl:with-param name="var" select="'MEM_RESERVE'" />
            </xsl:call-template>
            <xsl:call-template  name="State">
                <xsl:with-param name="flag" select="MEM_DECOMMIT" />
                <xsl:with-param name="var" select="'MEM_DECOMMIT'" />
            </xsl:call-template>
            <xsl:call-template  name="State">
                <xsl:with-param name="flag" select="MEM_RELEASE" />
                <xsl:with-param name="var" select="'MEM_RELEASE'" />
            </xsl:call-template>
            <xsl:call-template  name="State">
                <xsl:with-param name="flag" select="MEM_FREE" />
                <xsl:with-param name="var" select="'MEM_FREE'" />
            </xsl:call-template>

        </xsl:element>
    </xsl:template>

    <!-- TYPE -->
    <xsl:template match="Type">
        <xsl:element name="ObjectValue">
            <xsl:attribute name="name">Type</xsl:attribute>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="MEM_PRIVATE" />
                <xsl:with-param name="var" select="'MEM_PRIVATE'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="MEM_MAPPED" />
                <xsl:with-param name="var" select="'MEM_MAPPED'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="MEM_RESET" />
                <xsl:with-param name="var" select="'MEM_RESET'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="MEM_TOP_DOWM" />
                <xsl:with-param name="var" select="'MEM_TOP_DOWN'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="MEM_WRITE_WATCH" />
                <xsl:with-param name="var" select="'MEM_WRITE_WATCH'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="MEM_PHYSICAL" />
                <xsl:with-param name="var" select="'MEM_PHYSICAL'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="MEM_LARGE_PAGES" />
                <xsl:with-param name="var" select="'MEM_LARGE_PAGES'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="MEM_4MB_PAGES" />
                <xsl:with-param name="var" select="'MEM_4MB_PAGES'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="SEC_FILE" />
                <xsl:with-param name="var" select="'SEC_FILE'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="SEC_IMAGE" />
                <xsl:with-param name="var" select="'SEC_IMAGE'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="SEC_RESERVED" />
                <xsl:with-param name="var" select="'SEC_RESERVED'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="SEC_COMMIT" />
                <xsl:with-param name="var" select="'SEC_COMMIT'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="SEC_NOCACHE" />
                <xsl:with-param name="var" select="'SEC_NOCACHE'" />
            </xsl:call-template>
            <xsl:call-template  name="Type">
                <xsl:with-param name="flag" select="MEM_IMAGE" />
                <xsl:with-param name="var" select="'MEM_IMAGE'" />
            </xsl:call-template>

        </xsl:element>
    </xsl:template>

    <!-- REGION USAGE -->
    <xsl:template match="RegionUsage">
        <xsl:element name="ObjectValue">
            <xsl:attribute name="name">RegionUsage</xsl:attribute>
            <xsl:call-template  name="RegionUsageFlags">
                <xsl:with-param name="flag" select="MD_REGION_USAGE_STACK" />
                <xsl:with-param name="var" select="'MD_REGION_USAGE_STACK'" />
            </xsl:call-template>
            <xsl:call-template  name="RegionUsageFlags">
                <xsl:with-param name="flag" select="MD_REGION_USAGE_HEAP" />
                <xsl:with-param name="var" select="'MD_REGION_USAGE_HEAP'" />
            </xsl:call-template>
            <xsl:call-template  name="RegionUsageFlags">
                <xsl:with-param name="flag" select="MD_REGION_USAGE_PEB" />
                <xsl:with-param name="var" select="'MD_REGION_USAGE_PEB'" />
            </xsl:call-template>
            <xsl:call-template  name="RegionUsageFlags">
                <xsl:with-param name="flag" select="MD_REGION_USAGE_TEB" />
                <xsl:with-param name="var" select="'MD_REGION_USAGE_TEB'" />
            </xsl:call-template>
            <xsl:call-template  name="RegionUsageFlags">
                <xsl:with-param name="flag" select="MD_REGION_USAGE_MAIN_IMAGE" />
                <xsl:with-param name="var" select="'MD_REGION_USAGE_MAIN_IMAGE'" />
            </xsl:call-template>
            <xsl:call-template  name="RegionUsageFlags">
                <xsl:with-param name="flag" select="MD_REGION_USAGE_VALID_IMAGE" />
                <xsl:with-param name="var" select="'MD_REGION_USAGE_VALID_IMAGE'" />
            </xsl:call-template>
            <xsl:call-template  name="RegionUsageFlags">
                <xsl:with-param name="flag" select="MD_REGION_USAGE_HIDDEN_IMAGE" />
                <xsl:with-param name="var" select="'MD_REGION_USAGE_HIDDEN_IMAGE'" />
            </xsl:call-template>
            <xsl:call-template  name="RegionUsageFlags">
                <xsl:with-param name="flag" select="MD_REGION_USAGE_PE_HEADER" />
                <xsl:with-param name="var" select="'MD_REGION_USAGE_PE_HEADER'" />
            </xsl:call-template>

        </xsl:element>
    </xsl:template>

	<!-- Allocation protect -->
	<xsl:template name="Protect">
		<xsl:param name="flag"/>
		<xsl:param name="var" />

		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$flag">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<!-- State -->
	<xsl:template name="State">
		<xsl:param name="flag"/>
		<xsl:param name="var" />

		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$flag">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<!-- Type -->
	<xsl:template name="Type">
		<xsl:param name="flag"/>
		<xsl:param name="var" />

		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$flag">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<!-- Region usage -->
	<xsl:template name="RegionUsageFlags">
		<xsl:param name="flag"/>
		<xsl:param name="var" />

		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$flag">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

</xsl:transform>
