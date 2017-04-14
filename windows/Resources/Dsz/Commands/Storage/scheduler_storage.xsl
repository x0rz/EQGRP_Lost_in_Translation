<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Jobs"/>
			<xsl:apply-templates select="NewJob"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Jobs">
		<xsl:apply-templates select="AtJob"/>
		<xsl:apply-templates select="NetJob"/>
		<xsl:apply-templates select="TaskServiceFolder"/>
	</xsl:template>
	
	<xsl:template match="AtJob">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AtJob</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">CommandText</xsl:attribute>
				<xsl:value-of select="CommandText"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">frequency</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Flags/JobRunsToday">
						<xsl:text>Today</xsl:text>
					</xsl:when>
					<xsl:when test="Flags/JobRunPeriodically">
						<xsl:text>Each</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Next</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Weekday</xsl:attribute>
				<xsl:value-of select="Weekday/@days"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Month</xsl:attribute>
				<xsl:value-of select="Monthday/@days"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Time</xsl:attribute>
				<xsl:variable name="hour" select="substring-before(substring-after(Time, 'T'), 'H')" />
				<xsl:variable name="minute" select="substring-before(substring-after(Time, 'H'), 'M')" />
				<xsl:variable name="timeString" select="concat($hour, ':', $minute)"/>	
				<xsl:value-of select="$timeString"/>		
			</xsl:element>		
		</xsl:element>
	</xsl:template>
		
	<xsl:template match="NetJob">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">NetJob</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">exitcode</xsl:attribute>
				<xsl:value-of select="@exitcode"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">JobName</xsl:attribute>
				<xsl:value-of select="JobName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">FlagsMask</xsl:attribute>
				<xsl:value-of select="Flags/@mask"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">NextRunDate</xsl:attribute>
				<xsl:value-of select="substring-before(NextRun, 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">NextRunTime</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(NextRun, 'T'), '.')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Application</xsl:attribute>
				<xsl:value-of select="Application"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Parameters</xsl:attribute>
				<xsl:value-of select="Parameters"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Account</xsl:attribute>
				<xsl:value-of select="Account"/>
			</xsl:element>
			<xsl:apply-templates select="Triggers" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Triggers">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Trigger</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">TriggerString</xsl:attribute>
				<xsl:value-of select="Trigger"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="NewJob">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">NewJob</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@id" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="TaskServiceFolder">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Folder</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Path</xsl:attribute>
				<xsl:value-of select="@path"/>
			</xsl:element>
			<xsl:for-each select="Job">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Job</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Name</xsl:attribute>
						<xsl:value-of select="@name"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Path</xsl:attribute>
						<xsl:value-of select="@path"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Compatibility</xsl:attribute>
						<xsl:value-of select="@compatibility"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">LastRunResult</xsl:attribute>
						<xsl:value-of select="@lastRunResult"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">NumMissedRuns</xsl:attribute>
						<xsl:value-of select="@numMissedRuns"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">State</xsl:attribute>
						<xsl:value-of select="@state"/>
					</xsl:element>
					<xsl:element name="BoolValue">
						<xsl:attribute name="name">Disabled</xsl:attribute>
						<xsl:choose>
							<xsl:when test="@state = 'DISABLED'">
								<xsl:text>true</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>false</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:call-template name="StoreTime">
						<xsl:with-param name="time" select="NextRunTime"/>
						<xsl:with-param name="name" select="'NextRunTime'"/>
					</xsl:call-template>
					<xsl:call-template name="StoreTime">
						<xsl:with-param name="time" select="LastRunTime"/>
						<xsl:with-param name="name" select="'LastRunTime'"/>
					</xsl:call-template>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Xml</xsl:attribute>
						<xsl:value-of select="Xml"/>
					</xsl:element>

					<xsl:for-each select="Action">
						<xsl:element name="ObjectValue">
							<xsl:attribute name="name">Action</xsl:attribute>
							<xsl:element name="StringValue">
								<xsl:attribute name="name">Type</xsl:attribute>
								<xsl:value-of select="@type"/>
							</xsl:element>
							<xsl:element name="StringValue">
								<xsl:attribute name="name">Id</xsl:attribute>
								<xsl:value-of select="Id"/>
							</xsl:element>
							<xsl:if test="Exec">
								<xsl:element name="ObjectValue">
									<xsl:attribute name="name">Exec</xsl:attribute>
									<xsl:element name="StringValue">
										<xsl:attribute name="name">Path</xsl:attribute>
										<xsl:value-of select="Exec/Path"/>
									</xsl:element>
									<xsl:element name="StringValue">
										<xsl:attribute name="name">Arguments</xsl:attribute>
										<xsl:value-of select="Exec/Arguments"/>
									</xsl:element>
									<xsl:element name="StringValue">
										<xsl:attribute name="name">WorkingDir</xsl:attribute>
										<xsl:value-of select="Exec/WorkingDir"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="COM">
								<xsl:element name="ObjectValue">
									<xsl:attribute name="name">COM</xsl:attribute>
									<xsl:element name="StringValue">
										<xsl:attribute name="name">ClassId</xsl:attribute>
										<xsl:value-of select="COM/ClassId"/>
									</xsl:element>
									<xsl:element name="StringValue">
										<xsl:attribute name="name">Data</xsl:attribute>
										<xsl:value-of select="COM/Data"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:for-each>

					<xsl:element name="ObjectValue">
						<xsl:attribute name="name">Principal</xsl:attribute>
						<xsl:element name="StringValue">
							<xsl:attribute name="name">LogonType</xsl:attribute>
							<xsl:value-of select="Principal/@logonType"/>
						</xsl:element>
						<xsl:element name="StringValue">
							<xsl:attribute name="name">RunLevel</xsl:attribute>
							<xsl:value-of select="Principal/@runLevel"/>
						</xsl:element>
						<xsl:element name="StringValue">
							<xsl:attribute name="name">DisplayName</xsl:attribute>
							<xsl:value-of select="Principal/DisplayName"/>
						</xsl:element>
						<xsl:element name="StringValue">
							<xsl:attribute name="name">GroupId</xsl:attribute>
							<xsl:value-of select="Principal/GroupId"/>
						</xsl:element>
						<xsl:element name="StringValue">
							<xsl:attribute name="name">Id</xsl:attribute>
							<xsl:value-of select="Principal/Id"/>
						</xsl:element>
						<xsl:element name="StringValue">
							<xsl:attribute name="name">UserId</xsl:attribute>
							<xsl:value-of select="Principal/UserId"/>
						</xsl:element>
					</xsl:element>

					<xsl:for-each select="Trigger">
						<xsl:element name="ObjectValue">
							<xsl:attribute name="name">Trigger</xsl:attribute>
							<xsl:element name="StringValue">
								<xsl:attribute name="name">Type</xsl:attribute>
								<xsl:value-of select="@type"/>
							</xsl:element>
							<xsl:element name="BoolValue">
								<xsl:attribute name="name">Enabled</xsl:attribute>
								<xsl:choose>
									<xsl:when test="@enabled = 'true'">
										<xsl:text>true</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>false</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
							<xsl:element name="StringValue">
								<xsl:attribute name="name">Id</xsl:attribute>
								<xsl:value-of select="Id"/>
							</xsl:element>
							<xsl:element name="StringValue">
								<xsl:attribute name="name">StartBoundary</xsl:attribute>
								<xsl:value-of select="StartBoundary"/>
							</xsl:element>
							<xsl:element name="StringValue">
								<xsl:attribute name="name">EndBoundary</xsl:attribute>
								<xsl:value-of select="EndBoundary"/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template name="StoreTime">
		<xsl:param name="time"/>
		<xsl:param name="name"/>

		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$name"/>
			</xsl:attribute>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="$time/@type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Date</xsl:attribute>
				<xsl:value-of select="substring-before($time, 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Time</xsl:attribute>
				<xsl:value-of select="substring-after($time, 'T')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>