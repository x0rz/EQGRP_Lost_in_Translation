<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Sql">
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="child::*[node()]"/>
	</xsl:template>

	<!-- Maximum length do display for a column -->
	<xsl:variable name="MaxColWidth">
		<xsl:value-of select="256"/>
	</xsl:variable>
	
	<xsl:variable name="MinColWidth">
		<xsl:value-of select="4"/>
	</xsl:variable>

	<!--Don't need to output this -->
	<xsl:template match="CommandInfo"/>
	<xsl:template match="DeleteEnv"/>

	<xsl:template match="Error">
		<xsl:text>*</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>* SQL Error Code: </xsl:text>
		<xsl:value-of select="ErrorCode"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>* SQL State Code: </xsl:text>
		<xsl:value-of select="SqlState"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>* </xsl:text>
		<xsl:value-of select="Message"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>*</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Handles">
		<xsl:apply-templates select="Connection"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Connection">
		<xsl:if test="Status">
			<xsl:if test="Status = 'Opened'">
				<xsl:text>Opened connection to database</xsl:text>
			</xsl:if>
			<xsl:if test="Status = 'Closed'">
				<xsl:text>Closed connection to database</xsl:text>
			</xsl:if>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:text>--------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>           Handle : </xsl:text>
		<xsl:value-of select="HandleId"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>     Connect Type : </xsl:text>
		<xsl:value-of select="ConnectType"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      Access Type : </xsl:text>
		<xsl:value-of select="AccessType"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      Auto Commit : </xsl:text>
		<xsl:value-of select="AutoCommit"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      Create Time : </xsl:text>
		<xsl:call-template name="printTime">
			<xsl:with-param name="time" select="CreateTime"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>    Last Use Time : </xsl:text>
		<xsl:call-template name="printTime">
			<xsl:with-param name="time" select="LastUseTime"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>Max Idle Duration : </xsl:text>
		<xsl:call-template name="printTime">
			<xsl:with-param name="time" select="MaxIdleDuration"/>
			<xsl:with-param name="formatDelta" select="'true'"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>   Connect String : </xsl:text>
		<xsl:value-of select="ConnectString"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Drivers">
		<xsl:text>Driver Name                                                 Attributes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>----------------------------------------------------------- -------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Driver"/>
	</xsl:template>

	<xsl:template match="Driver">
		<xsl:variable name="Warning">
			<xsl:choose>
				<xsl:when test="Warning">
					<xsl:text>[</xsl:text>
					<xsl:value-of select="Warning"/>
					<xsl:text>]</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Name">
			<xsl:value-of select="Name"/>
			<xsl:value-of select="$Warning"/>
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="60 - (string-length(Name) + string-length($Warning))"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="Warning">
				<!-- we don't want to display it, so nothing goes here -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Name"/>
				<xsl:value-of select="Attributes"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Sources">
		<xsl:text>Data Source                                       Description</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>------------------------------------------------- -------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="DataSource"/>
	</xsl:template>

	<xsl:template match="DataSource">
		<xsl:variable name="Name">
			<xsl:value-of select="Name"/>
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="50 - string-length(Name)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="Warning">
				<!-- we don't want to display it, so nothing goes here -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Name"/>
				<xsl:value-of select="Description"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Servers">
		<xsl:text>Server</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>-------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:for-each select="Server">
			<xsl:value-of select="."/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="Databases">
		<xsl:call-template name="DisplayColumns"/>
	</xsl:template>

	<xsl:template match="Tables">
		<xsl:call-template name="DisplayColumns"/>
	</xsl:template>

	<xsl:template match="Columns">
		<xsl:call-template name="DisplayColumns"/>
	</xsl:template>

	<xsl:template match="Query">
		<xsl:call-template name="DisplayColumns"/>
	</xsl:template>

	<!--Common format for Tables, Columns and Query-->
	<xsl:template name="DisplayColumns">

		<!--Variables to manage column width output-->
		<xsl:variable name="CommandString">
			<xsl:value-of select="Command"/>
		</xsl:variable>

		<xsl:variable name="TotalColumns">
			<xsl:value-of select="TotalColumns"/>
		</xsl:variable>

		<!--Output summary details-->
		<xsl:text>Command : </xsl:text>
		<xsl:value-of select="$CommandString"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Collected </xsl:text>
		<xsl:value-of select="$TotalColumns"/>
		<xsl:text> Columns for Rows </xsl:text>
		<xsl:value-of select="StartRow"/>
		<xsl:text> - </xsl:text>
		<xsl:value-of select="EndRow"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Number of Rows Modified : </xsl:text>
		<xsl:value-of select="CountRows"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>

		<!--Output column names-->
		<xsl:for-each select="ColumnInfo/Column">
			<xsl:variable name="ColumnWidth">
				<xsl:choose>
					<xsl:when test="ColumnWidth &gt; $MaxColWidth">
						<xsl:value-of select="$MaxColWidth"/>
					</xsl:when>
					<xsl:when test="string-length(Name) &gt; ColumnWidth">
						<xsl:value-of select="string-length(Name)"/>
					</xsl:when>
					<xsl:when test="ColumnWidth &lt; $MinColWidth">
						<xsl:value-of select="$MinColWidth"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="ColumnWidth"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="Name">
				<xsl:choose>
					<xsl:when test="string-length(Name) &gt; $ColumnWidth">
						<xsl:value-of select="substring(Name, 0, $ColumnWidth - 2)"/>
						<xsl:text>...</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="Name"/>
						<xsl:call-template name="Whitespace">
							<xsl:with-param name="i" select="$ColumnWidth - string-length(Name)"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="$Name"/>
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:call-template name="PrintReturn"/>

		<!--We limit the maximum number of characters to display to 256-->
		<!--Without the limit some returned data could be too big and cause the transformation to error out-->
		<!--Output table divider-->
		<xsl:for-each select="ColumnInfo/Column">
			<xsl:variable name="ColumnWidth">
				<xsl:choose>
					<xsl:when test="ColumnWidth &gt; $MaxColWidth">
						<xsl:value-of select="$MaxColWidth"/>
					</xsl:when>
					<xsl:when test="string-length(Name) &gt; ColumnWidth">
						<xsl:value-of select="string-length(Name)"/>
					</xsl:when>
					<xsl:when test="ColumnWidth &lt; $MinColWidth">
						<xsl:value-of select="$MinColWidth"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="ColumnWidth"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:call-template name="CharFill">
				<xsl:with-param name="i"    select="$ColumnWidth"/>
				<xsl:with-param name="char" select="'-'"/>
			</xsl:call-template>

			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:call-template name="PrintReturn"/>

		<!--Output data-->
		<xsl:for-each select="UncompressedData/TableRow">
			<xsl:for-each select="TableData">

				<!--Record which column we are in-->
				<xsl:variable name="CurrentColumnPosition">
					<xsl:value-of select="position()"/>
				</xsl:variable>

				<!--Get the width of this column-->
				<xsl:variable name="CurrentColumnWidth">
					<xsl:choose>
						<xsl:when test="../../../ColumnInfo/Column[position()=$CurrentColumnPosition]/ColumnWidth &gt; $MaxColWidth">
							<xsl:value-of select="$MaxColWidth"/>
						</xsl:when>
						<xsl:when test="../../../ColumnInfo/Column[position()=$CurrentColumnPosition]/ColumnWidth &lt; string-length(../../../ColumnInfo/Column[position()=$CurrentColumnPosition]/Name)">
							<xsl:value-of select="string-length(../../../ColumnInfo/Column[position()=$CurrentColumnPosition]/Name)"/>
						</xsl:when>
						<xsl:when test="../../../ColumnInfo/Column[position()=$CurrentColumnPosition]/ColumnWidth &lt; $MinColWidth">
							<xsl:value-of select="$MinColWidth"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="../../../ColumnInfo/Column[position()=$CurrentColumnPosition]/ColumnWidth"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!--Output the entry, padding with whitespace to column width-->
				<xsl:variable name="Entry">
					<xsl:variable name="EntryText">
						<xsl:choose>
							<xsl:when test="../../../ColumnInfo/Column[position()=$CurrentColumnPosition]/IsBinary = 'true'">
								<xsl:choose>
									<xsl:when test=". = ''">
										<xsl:value-of select="'NULL'"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="'(Bin) '"/>
										<xsl:value-of select="@bytes"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test=". = ''">
										<xsl:value-of select="'NULL'"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="@truncated = 'true'">
							<xsl:choose>
								<xsl:when test="../../../ColumnInfo/Column[position()=$CurrentColumnPosition]/IsBinary = 'true' and string-length($EntryText) &lt; $CurrentColumnWidth">
									<xsl:value-of select="$EntryText"/>
									<xsl:call-template name="Whitespace">
										<xsl:with-param name="i" select="$CurrentColumnWidth - string-length($EntryText)"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="(string-length($EntryText) + 2) &lt; $CurrentColumnWidth">
									<xsl:value-of select="$EntryText"/>
									<xsl:text>...</xsl:text>
									<xsl:call-template name="Whitespace">
										<xsl:with-param name="i" select="$CurrentColumnWidth - (string-length($EntryText) + 2)"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring($EntryText, 0, $CurrentColumnWidth - 2)"/>
									<xsl:text>...</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string-length($EntryText) &lt; $CurrentColumnWidth">
									<xsl:value-of select="$EntryText"/>
									<xsl:call-template name="Whitespace">
										<xsl:with-param name="i" select="$CurrentColumnWidth - string-length($EntryText)"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$EntryText"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>	
				</xsl:variable>
				<xsl:value-of select="$Entry"/>
				<xsl:text> </xsl:text>

			</xsl:for-each>
			<xsl:call-template name="PrintReturn"/>
		</xsl:for-each>

	</xsl:template>

</xsl:transform>