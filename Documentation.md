# Pulse Survey Database Schema Documentation

## Overview
This database schema supports a pulse survey system that captures survey responses across different geographic areas, demographic groups, and survey cycles. The schema consists of 5 interconnected tables with a central fact table linking to various dimension tables.

## Table Descriptions

### 1. PULSE_SURVEY
**Purpose**: Central data table storing survey response data
**Records**: Weeks 34 - 41

| Column | Data Type | Description |
|--------|-----------|-------------|
| cycle_type | VARCHAR | Type of survey cycle (e.g., "quarterly", "annual") |
| cycle_number | INTEGER | Sequential number identifying the specific cycle |
| geo_id | INTEGER | Foreign key linking to geographic_areas table |
| demo_id | INTEGER | Foreign key linking to demo_groups table |
| question_id | INTEGER | Foreign key linking to questions table |
| response_id | INTEGER | Foreign key linking to responses table |
| value | INTEGER | Numeric value representing response frequency/count |

**Relationships**: 
- Links to all other tables via foreign keys
- Serves as the central hub for survey analytics

### 2. GEOGRAPHIC_AREAS (Dimension Table)
**Purpose**: Master table of geographic locations where surveys are conducted
**Records**: 67 rows

| Column | Data Type | Description |
|--------|-----------|-------------|
| geo_id | INTEGER | Primary key, unique identifier for geographic area |
| geo_code | VARCHAR | Short code/abbreviation for the geographic area |
| geo_name | VARCHAR | Full name of the geographic area |
| geo_type | VARCHAR | Classification of area (e.g., "state", "county", "city") |
| fips_code | FLOAT | Federal Information Processing Standards code (may be null) |

**Key Features**:
- Supports hierarchical geographic analysis
- FIPS codes enable integration with federal datasets

### 3. DEMO_GROUPS (Dimension Table)
**Purpose**: Demographic classification system for survey respondents
**Records**: 100 rows

| Column | Data Type | Description |
|--------|-----------|-------------|
| demo_id | INTEGER | Primary key, unique identifier for demographic group |
| demo_option | VARCHAR | Specific demographic value (e.g., "25-34", "Male", "College Graduate") |
| demo_category | VARCHAR | Broader demographic category (e.g., "Age", "Gender", "Education") |

**Key Features**:
- Enables multi-dimensional demographic analysis
- Supports grouping by category for rollup reporting

### 4. QUESTIONS (Dimension Table)
**Purpose**: Master list of survey questions
**Records**: 3 rows

| Column | Data Type | Description |
|--------|-----------|-------------|
| question_id | INTEGER | Primary key, unique identifier for each question |
| question | VARCHAR | Full text of the survey question |
| question_short_name | VARCHAR | Abbreviated name for reporting/display purposes |

**Key Features**:
- Small, stable dimension for question metadata
- Short names facilitate dashboard creation

### 5. RESPONSES (Dimension Table)
**Purpose**: Standardized response options across surveys
**Records**: 5 rows

| Column | Data Type | Description |
|--------|-----------|-------------|
| response_id | INTEGER | Primary key, unique identifier for each response option |
| response | VARCHAR | Full text of the response option |
| response_short_name | VARCHAR | Abbreviated response for reporting/display |

**Key Features**:
- Standardizes response scales across questions
- Supports consistent analysis and visualization

## Entity Relationship Diagram (Conceptual)

```
GEOGRAPHIC_AREAS (1) ────┐
                         │
DEMO_GROUPS (1) ─────────┼─── (Many) PULSE_SURVEY
                         │
QUESTIONS (1) ───────────┤
                         │
RESPONSES (1) ───────────┘
```

## Key Relationships

1. **One-to-Many Relationships**: Each dimension table has a one-to-many relationship with the fact table
2. **Star Schema Design**: Classic star schema with central fact table surrounded by dimension tables
3. **Foreign Key Constraints**: All _id fields in the fact table reference primary keys in dimension tables

## Usage Patterns

**Typical Queries**:
- Response distribution by demographic groups
- Geographic comparison of survey results
- Trend analysis across survey cycles
- Cross-tabulation of questions by demographics and geography

**Performance Considerations**:
- Consider clustering the fact table on frequently queried dimensions (geo_id, cycle_number)
- Dimension tables are small and will benefit from Snowflake's automatic clustering