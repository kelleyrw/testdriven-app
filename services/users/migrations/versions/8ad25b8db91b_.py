"""empty message

Revision ID: 8ad25b8db91b
Revises: 
Create Date: 2019-06-04 16:25:59.810143

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "8ad25b8db91b"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column("users", sa.Column("password", sa.String(length=255)))
    op.execute("UPDATE users SET password=email")
    op.alter_column("users", "password", nullable=False)
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column("users", "password")
    # ### end Alembic commands ###
